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
