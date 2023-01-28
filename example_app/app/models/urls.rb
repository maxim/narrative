# All url helpers are available on the global Urls object.
class Urls
  class << self
    include Rails.application.routes.url_helpers
  end
end
