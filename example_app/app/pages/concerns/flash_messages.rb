# Useful to instantiate pages in the controller from flash messages.
# If you only instantiate from flash, you can do `MyPage.from_flash(flash)`.
# If you instantiate from something else and flash, you can use `flash_args`:
#
#     class MyPage < ApplicationStruct
#       extend FlashMessages
#
#       class << self
#         def from_user(user, flash)
#           new name: user.name, **flash_args(flash)
#         end
#       end
#
#       keyword :name
#     end
module FlashMessages
  def from_flash(flash) = new(**flash_args(flash))
  def flash_args(flash) = {notice: flash[:notice], alert: flash[:alert]}

  def self.extended(base)
    base.keyword :notice, default: nil
    base.keyword :alert, default: nil
  end
end
