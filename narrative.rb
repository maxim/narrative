gem "portrayal"

gem_group :development, :test do
  gem "standard", require: false

  gem "rubocop-rails",         require: false
  gem "rubocop-minitest",      require: false
  gem "rubocop-performance",   require: false
  gem "rubocop-rake",          require: false
  gem "rubocop-thread_safety", require: false

  gem "bundler-audit", require: false
  gem "brakeman", require: false
end

file ".rubocop.yml", <<~YAML
  require:
    - standard
    - rubocop-rails
    - rubocop-minitest
    - rubocop-performance
    - rubocop-rake
    - rubocop-thread_safety

  inherit_gem:
    standard: config/base.yml

  AllCops:
    TargetRubyVersion: 3.1
    NewCops: enable
    Exclude:
      - public/**/*
      - vendor/**/*
      - bin/bundle
      - db/schema.rb

  Bundler:
    Enabled: true

  Rails:
    Enabled: true

  Layout/LineLength:
    Max: 80

  # Support aligning things like:
  #
  # first_key  = value
  # second_key = value
  # third_key  = value
  Layout/ExtraSpacing:
    AllowForAlignment: true

  # We want to support aligning hashes in both key and table styles, but rubocop
  # forces us to choose one, therefore this is disabled.
  Layout/HashAlignment:
    Enabled: false

  # Support one-liner defs to be on adjacent lines:
  #
  #   def hello = "hello"
  #   def world = "world"
  Layout/EmptyLineBetweenDefs:
    AllowAdjacentOneLineDefs: true

  # These files often have extra empty lines out of the box. No harm in allowing
  # it in such a comment-heavy place.
  Layout/EmptyLines:
    Exclude:
      - config/environments/*

  # Leave this up to readability assessment.
  Layout/SpaceInsideArrayLiteralBrackets:
    Enabled: false

  # Leave this up to readability assessment.
  Layout/SpaceInsideHashLiteralBraces:
    Enabled: false

  # Leave this up to readability assessment.
  Layout/SpaceInsidePercentLiteralDelimiters:
    Enabled: false

  # Forces parentheses on `foo **kwargs`. Sometimes these parentheses make
  # readability worse.
  Lint/AmbiguousOperator:
    Enabled: false

  # We use regexp as first arg in assert_match, there doesn't seem to be any
  # ambiguity with it.
  Lint/AmbiguousRegexpLiteral:
    Enabled: false

  # Multiple assertions per test are okay in some situations.
  Minitest/MultipleAssertions:
    Enabled: false

  # For small tests keeping 2 lines together looks prettier.
  Minitest/EmptyLineBeforeAssertionMethods:
    Enabled: false

  # We don't want to restrict this choice. Regular `alias` is better for static
  # alias and auto-documentation (most cases). And `alias_method` can be used for
  # runtime metaprogramming.
  Style/Alias:
    Enabled: false

  # Depending on a situation, both foo.() and foo.call are legit.
  Style/LambdaCall:
    Enabled: false

  # More trouble than it's worth. Inconsistency for string literals is okay.
  Style/StringLiterals:
    Enabled: false

  # Class-instance variables are okay for inheritability.
  ThreadSafety/InstanceVariableInClassMethod:
    Enabled: false
YAML

## ApplicationStruct

file 'app/models/application_struct.rb', <<~RUBY
  require "camelize_json_keys"

  class ApplicationStruct
    extend Portrayal
    include ActiveModel::Model
    include ActiveModel::Serializers::JSON
    include CamelizeJsonKeys.first_letter(:lower)

    def attributes = self.class.portrayal.attributes(self)
    alias to_h attributes

    def as_json(*) = super.compact
  end
RUBY

lib "camelize_json_keys.rb", <<~RUBY
  # USAGE
  #
  # class MyClass
  #   include CamelizeJsonKeys.first_letter(:lower) # or :upper
  #   …
  # end
  module CamelizeJsonKeys
    class << self
      def first_letter(first_letter_style)
        Module.new do
          define_method(:as_json) do |*args, **kwargs|
            super(*args, **kwargs).deep_transform_keys { |key|
              key.to_s.camelize(first_letter_style)
            }
          end
        end
      end
    end
  end
RUBY

# Page Objects

file 'app/pages/README.md', <<~MARKDOWN
  # Page objects

  Whenever we need to render a page, regardless whether it's formatted as JSON or HTML, we must have a page object.

  A page object follows the structure of the content on that page, and can be directly turned into JSON if needed.

  Example page object:

  ```ruby
  class WelcomePage < ApplicationStruct
    extend FlashMessages

    keyword :greeting_name
    keyword :greeting_time_of_day # "good afternoon", "good evening"

    keyword :favorite_links, default: [].freeze, define: "FavoriteLink" do
      keyword :image_path
      keyword :url
    end
  end
  ```

  For more info on page objects check [this blog post](https://max.engineer/server-informed-ui).
MARKDOWN

file 'app/pages/concerns/flash_messages.rb', <<~RUBY
  # Useful to instantiate pages in the controller from flash messages.
  # If you only instantiate from flash, you can do `MyPage.from_flash(flash)`.
  # If you instantiate from something else and flash, you can use `flash_args`:
  #
  #     class MyPage < ApplicationStruct
  #       extend FlashMessages
  #
  #       class << self
  #         def from_user(user, flash)
  #           new name: user.name, **flash_args(flash)
  #         end
  #       end
  #
  #       keyword :name
  #     end
  module FlashMessages
    def from_flash(flash) = new(**flash_args(flash))
    def flash_args(flash) = {notice: flash[:notice], alert: flash[:alert]}

    def self.extended(base)
      base.keyword :notice, default: nil
      base.keyword :alert, default: nil
    end
  end
RUBY

## Form Objects

file 'app/forms/README.md', <<~MARKDOWN
  # Form objects

  Form objects have the following uses:

  1. They define form fields in page objects.
  2. They help you use `form_with` Rails helper.
  3. They help you require/permit only allowed params.
  4. They validate params.
  5. They help you save params. (But they DO NOT do the actual saving)
  6. They make your forms JSON-compatible.

  Here's an example of how to write a form object:

  ```ruby
  class MyForm < ApplicationForm
    action Urls.the_action_path, method: :get # method is optional

    keyword :field1
    keyword :field2

    validates :field1, presence: true
    validates :field2, format: { with: /\A\d+\z/ }
  end
  ```

  Here's how to work with this object in each of the mentioned uses:

  ### 1. Defining form in a page object

  ```ruby
  class MyPage < ApplicationStruct
    class << self
      def from_params(params) = new(form: MyForm.from_params(params))
    end

    keyword :form, default: proc { MyForm.new }
  end
  ```

  ### 2. Using `form_with` helper

  ```erb
  <%= form_with **@page.form.with, class: "css-class" do |form| %>
  ```

  ### 3. Requiring/permitting params

  ```ruby
  def create
    # This line will require/permit only your declared form fields.
    @page = MyPage.from_params(params)
  ```

  ### 4. Validating params

  You can call `@page.form.valid?` or `@page.form.invalid?`, and decide how to proceed in a controller action.

  ### 5. Saving params

  After you validated the form, you can go ahead and update all the necessary models in the controller:

  ```ruby
  user.update!(@page.form.attributes)
  ```

  ### 6. Working with JSON

  Forms have `as_json` and `to_json`. The produced JSON contains everything that the front-end requires to be able to render the form. This includes validation errors if any.
MARKDOWN

file 'app/forms/application_form.rb', <<~RUBY
  class ApplicationForm < ApplicationStruct
    class << self
      attr_reader :default_action, :default_method

      def action(url, method: nil)
        @default_action = url
        @default_method = method
      end

      def model_name
        @_model_name ||= ActiveModel::Name.new(self, nil, name.demodulize)
      end

      def attribute_names     = portrayal.keywords.without(:action, :method)
      def from_params(params) = new(**filter_params(params))

      def filter_params(params)
        params
          .require(model_name.param_key)
          .permit(*attribute_names)
          .to_hash
          .transform_keys(&:to_sym)
      end
    end

    keyword :action, default: proc { self.class.default_action }
    keyword :method, default: proc { self.class.default_method }

    def attributes   = super.slice(*self.class.attribute_names)
    def persisted?   = false
    def plural_error = "error".pluralize(errors.size)
    def with         = {model: self, url: action, method: method}

    def as_json(**kwargs)
      methods = Array(kwargs[:methods]) | %i[action method plural_error errors]
      super(**kwargs, methods: methods)
    end
  end
RUBY

file 'app/models/urls.rb', <<~RUBY
  # All url helpers are available on the global Urls object.
  class Urls
    class << self
      include Rails.application.routes.url_helpers
    end
  end
RUBY

## Cron Objects

file 'app/cron/README.md', <<~MARKDOWN
# Cron objects

For every cron cadence (i.e. daily at 10am, every 10 minutes, weekly on sunday morning, etc) you:

1. Add a new class into this directory. Name this class after the cadence, so it is clear when it runs.
2. Create a similar-named rake task in cron.rake, which will call the code in this class.
3. Hook up your deployment environments to run those rake tasks at the promised times.

Now all you need to do is keep adding code into these files, and when deployed, it will run at the right times.

## Isolating cron logic

Be mindful of errors. If you want to run 2 or more different jobs at this time, and you don't want an error in the first one to stop the second one, you can wrap each piece of code into an `isolate` block.

```ruby
class DailyAt1000UtcCron < ApplicationCron
  def call
    isolate { do_something }
    isolate { do_something_else }
  end
end
```
MARKDOWN

file 'app/cron/application_cron.rb', <<~RUBY
  class ApplicationCron
    # Wrap code into `isolate` blocks so that each block can error out without
    # stopping other blocks.
    def isolate
      yield
    rescue => e
      Rails.logger.error(e.message)
    end
  end
RUBY

file 'app/cron/daily_at_1000_utc_cron.rb', <<~RUBY
  class DailyAt1000UtcCron < ApplicationCron
    # 10:00 UTC
    #   ~ 02:00 Pacific
    #   ~ 05:00 Eastern
    #   ~ 11:00 Europe
    #
    # Note: exact times vary with DST.

    def call
    end
  end
RUBY

rakefile "cron.rake", <<~RUBY
  namespace :cron do
    desc "Runs daily at 10:00 UTC"
    task daily_at_1000_utc: :environment do
      Rails.logger = Logger.new($stdout)
      DailyAt1000UtcCron.new.call
      Rails.logger.info "Finished executing cron:daily_at_1000_utc"
    end
  end
RUBY

## Client objects

file 'app/clients/README.md', <<~MARKDOWN
# Client objects

Every integration with APIs must consist of 2 client libraries.

1. **External client**: The generic client library for the API. Usually it's provided by the API company itself. (E.g. AWS SNS gem for AWS SNS)
2. **Internal client**: The API client that we must write for using in our app.

## External client

If external client already exists, we install it as a gem. If it doesn't, we write a simple one for our needs, and put it under `lib`. Think of it as an open source client library that we are writing in-house.

If we must write an external client, it would look something like this:

```ruby
class SuperAwesomeSms < HTTPClient
  def initialize(creds)
    @creds = creds
  end

  def create_notification(text)
    http(@creds).post("example.com/notifications", text: text)
  end

  def get_notification_status(id)
    http(@creds).get("example.com/\#{id}/status")
  end
end
```

## Internal client

We must always write an internal client for our needs, and it should be placed here, under `app/clients`. It provides an interface for our application that we can mock. Our application should never use the external client directly.

An internal client would look something like this (based upon the external client above):

```ruby
class SmsClient
  def initialize(creds)
    @client = SuperAwesomeSms.new(creds)
  end

  def send_text(text)
    response = @client.create_notification(text)
    sleep 1 until get_notification_status(response.id) == "delivered"
    true
  end
end
```

## Rules for testing clients

1. Existing external clients don't need any additional tests from us.
2. In-house written external clients should have their own dedicated test suite (like any open source project would).
3. Internal clients must be tested against real API using something like [vcr](https://github.com/vcr/vcr).
4. Other application tests must mock internal clients.
```
MARKDOWN

## ADRs

file 'doc/adr/README.md', <<~MARKDOWN
# Architectural Decision Records

This directory contains Architectural Decision Records (ADRs) for this project. Any time you have made a decision that affects the architecture of the project, you should document it here.

## How to create a new ADR

1. Run `bin/rails generate adr activejob_adapter`
2. Edit the newly created file in `doc/adr/`
3. Commit the file
4. Send a PR
MARKDOWN

lib "generators/adr/USAGE", <<~TEXT
  Description:
      Generate an Architectural Decision Record with a placeholder template.

  Example:
      bin/rails generate adr activejob_adapter

      This will create:
          doc/adrs/2022-12-activejob-adapter.md
TEXT

lib "generators/adr/adr_generator.rb", <<~RUBY
  class AdrGenerator < Rails::Generators::NamedBase
    source_root File.expand_path("templates", __dir__)

    desc "Create a new architectural decision record file in doc/adr"
    def create_adr_file
      @today = Date.current
      prefix = @today.strftime("%Y-%m")
      template "adr.md", "doc/adr/\#{prefix}-\#{name.dasherize}.md"
    end
  end
RUBY

lib "generators/adr/templates/adr.md.tt", <<~MARKDOWN
  # <%= name.titleize %> (Short title of solved problem and solution)

  * **Status:** [proposed | rejected | approved | deprecated | superceded by [2021-01 Example](./2021-01-example.md)]
  * **Last Updated:** <%= @today %>
  * **Builds on:** [Short Title](./2021-05-short-title.md)
  * **Objective:** [description or link to contextual issue]

  ## Context & Problem Statement

  2-3 sentences explaining the problem and why it's challenging.

  ## Priorities & Constraints <!-- optional -->

  * list of concerns
  * that are influencing the decision

  ## Considered Options

  * Option 1: Thing
  * Option 2: Another

  ## Decision

  Chosen option [Option 1: Thing]

  [justification]

  ### Expected Consequences <!-- optional -->

  * List of unrelated outcomes this decision creates

  ### Revisiting this Decision <!-- optional -->

  ### Research <!-- optional -->

  * Resources reviewed as part of making this decision

  ## Links

  * Related PRs
  * Related User Journeys
MARKDOWN

file 'test/lib/generators/adr_generator_test.rb', <<~RUBY
  require "test_helper"
  require "generators/adr/adr_generator"

  class AdrGeneratorTest < Rails::Generators::TestCase
    tests AdrGenerator
    destination Rails.root.join("tmp/generators")
    setup :prepare_destination

    test "inserts correct name and date" do
      today = Date.current

      assert_nothing_raised do
        run_generator ["sample_adr"]
      end

      assert_file "doc/adr/\#{today.strftime("%Y-%m")}-sample-adr.md" do |file|
        assert_match(/# Sample Adr/, file.lines[0])
        assert_match("* **Last Updated:** \#{today}", file)
      end
    end
  end
RUBY

## Transactionality

file 'app/controllers/concerns/transactionality.rb', <<~RUBY
  # Use transactions in controllers to create procedural narratives.
  #
  #     transaction do
  #       track_something
  #       create_something
  #       send_email
  #     end
  module Transactionality
    def transaction = ActiveRecord::Base.transaction { yield }
  end
RUBY

inject_into_class \
  "app/controllers/application_controller.rb",
  "ApplicationController",
  "  include Transactionality\n"


## App config

file "config/#{app_name.underscore}.yml", <<~YAML
shared:
  app_name: #{app_name.titleize}
YAML

application "config.pocket = config_for(:#{app_name.underscore})"

## Rake tasks for testing

inject_into_file 'Rakefile', <<~RUBY, after: "Rails.application.load_tasks\n"

  require "rubocop/rake_task"
  RuboCop::RakeTask.new

  require "bundler/audit/task"
  Bundler::Audit::Task.new

  task default: %w[rubocop bundle:audit test]
RUBY

## ARCHITECTURE.md

file 'ARCHITECTURE.md', <<~MARKDOWN
  # Overview

  The app uses the _Narrative_ approach, which adds a few additional patterns to standard Rails. Each link will take you to their explanation.

  * [ApplicationStruct](app/models/application_struct.rb) - a slight enhancement over plain old ruby objects, with [portrayal](https://github.com/maxim/portrayal), ActiveModel, and better JSON support
  * [Page objects](app/pages) — presenter objects that work for both API and server-side rendering
  * [Form objects](app/forms) - param filters and validators that work for both API and server-side rendering
  * [Urls](app/models/urls.rb) - all URL helpers for use in pages and forms
  * [Cron objects](app/cron) - periodic jobs
  * [Client objects](app/clients) — app-specific adapters for API clients and SDKs
  * [ADRs](doc/adr) - architectural decision records
  * [Transactionality helper](app/controllers/concerns/transactionality.rb) - use transactions in controllers to create procedural narratives
  * [App config](config/#{app_name.underscore}.yml) - this is where the application-specific non-secret config goes
MARKDOWN

