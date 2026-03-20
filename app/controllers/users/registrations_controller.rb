class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # Auth is handled by Devise here; ensure no app-wide before_action blocks it.
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :verify_authenticity_token, raise: false

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        ok: true,
        user: {
          id: resource.id,
          email: resource.email,
          role: resource.role
        }
      }, status: :created
    else
      render json: {
        ok: false,
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def respond_to_on_destroy(_opts = {})
    render json: { ok: true }, status: :ok
  end
end
