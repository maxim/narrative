class ApplicationForm < ApplicationStruct
  class << self
    def action(url, method: nil)
      @action = url
      @method = method
    end

    def attribute_names     = portrayal.keywords.without(:action, :method)
    def default_action      = @action
    def default_method      = @method
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
