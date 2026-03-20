class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :authenticate_user!, unless: :public_path?

  def require_dispatcher!
    return if current_user.role == "dispatcher"
    render json: { error: "Forbidden" }, status: :forbidden
  end

  private

  def public_path?
    return true if request.method == "OPTIONS"
    request.path == "/users/sign_in" || request.path == "/users/sign_up"
  end
end
