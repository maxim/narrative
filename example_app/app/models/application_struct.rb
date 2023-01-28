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
