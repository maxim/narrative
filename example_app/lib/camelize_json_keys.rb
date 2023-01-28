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
