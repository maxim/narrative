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
* [App config](config/example_app.yml) - this is where the application-specific non-secret config goes
