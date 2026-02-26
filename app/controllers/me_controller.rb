class MeController < ApplicationController
  def show
    render json: {
      ok: true,
      user: {
        id: current_user.id,
        email: current_user.email,
        role: current_user.role,
        driver_id: current_user.driver_id
      }
    }
  end
end
