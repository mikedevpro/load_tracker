class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # SPA + cookie sessions
  skip_before_action :verify_authenticity_token, raise: false
  skip_before_action :authenticate_user!, raise: false

  private

  def respond_with(resource, _opts = {})
    # Successful sign in: resource is persisted and has an id
    if resource&.persisted?
      render json: {
        ok: true,
        user: { id: resource.id, email: resource.email, role: resource.role }
      }, status: :ok
    else
      # Failed sign in
      render json: {
        ok: false,
        error: "Invalid email or password"
      }, status: :unauthorized
    end
  end

  def respond_to_on_destroy(_opts = {})
    render json: { ok: true }, status: :ok
  end
end
