module DeviseHelper
  def devise_error_messages!
    error_messages_for @user
  end
end
