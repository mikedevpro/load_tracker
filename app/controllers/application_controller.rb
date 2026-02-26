class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :authenticate_user!

  def require_dispatcher!
    return if current_user.role == "dispatcher"
    render json: { error: "Forbidden" }, status: :forbidden
  end
end
