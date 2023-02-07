# Form objects

Form objects have the following uses:

1. They define form fields in page objects.
2. They help you use `form_with` Rails helper.
3. They help you require/permit only allowed params.
4. They validate params.
5. They help you save params. (But they DO NOT do the actual saving)
6. They make your forms JSON-compatible.
7. They help you check which form is submitted

Here's an example of how to write a form object:

```ruby
class MyForm < ApplicationForm
  action Urls.the_action_path, method: :get # method is optional

  keyword :field1
  keyword :field2

  validates :field1, presence: true
  validates :field2, format: { with: /Ad+z/ }
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

### 7. Checking which form is submitted

Sometimes one action handles multiple forms. Thanks to `===`, you can check like this:

```ruby
case params
when MyForm
  # do something
when MyOtherForm
  # do something else
end
```
