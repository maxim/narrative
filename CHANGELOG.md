## Unreleased

# 0.3.0

* Permit only public keywords in `ApplicationForm.filter_params`
* Relax and tweak rubocop:
  * Prefer fixed indentation for multi-line arguments
  * Allow positional args on first line, keywords on next lines
  * Prefer consistent indent in array literals
  * Prefer indenting method chains relative to receiver
  * Allow skipping model validations

## 0.2.0

* Rename ApplicationForm's `@action` and `@method` to `@default_action`, `@default_method` for consistency
* Exclude namespaces in form's `model_name`, because when you want to alter a form's action you can do it this way:

    ```ruby
    class MyPage < ApplicationStruct
      class MyForm < ::MyForm
        action Urls.different_than_in_superclass
      end

      keyword :form, default: proc { MyForm.new }
    end
    ```

  And you will still be getting `my_form` in your params, instead of `my_page_my_form`.

* Fix Rails compatibility bug in `ApplicationForm#as_json`
* Add `ApplicationForm.param_key` (returning `model_name.param_key`) for convenience
* Add `ApplicationForm.===`. This allows the following:

    ```ruby
    case params
    when SomeForm
      # do something
    when SomeOtherForm
      # do something else
    end
    ```

  Or simply:

    ```ruby
    if SomeForm === params
      # do something
    end
    ```

* Allow passing additional keywords in `ApplicationForm.from_params` and `FlashMessages.from_flash`

## 0.1.0

* Initial release
