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
