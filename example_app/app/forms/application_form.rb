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

    def ===(other) = other.respond_to?(:key?) ? other.key?(param_key) : super

    def param_key                 = model_name.param_key
    def attribute_names           = portrayal.keywords.without(:action, :method)
    def from_params(params, **kw) = new(**filter_params(params), **kw)

    def filter_params(params)
      params
        .require(param_key)
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

  def as_json(*args)
    options = args.extract_options!
    methods = Array(options[:methods]) | %i[action method plural_error errors]
    super(**options, methods: methods)
  end
end
