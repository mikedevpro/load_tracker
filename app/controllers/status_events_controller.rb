class StatusEventsController < ApplicationController
  def index
    load = Load.find(params[:load_id])

    if current_user.role == "driver" && load.driver_id != current_user.driver_id
      return render json: { error: "Forbidden" }, status: :forbidden
    end
    
    render json: load.status_events.order(occurred_at: :desc)
  end

  def create
    load = Load.find(params[:load_id])

    if current_user.role == "driver" && load.driver_id != current_user.driver_id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    event = load.status_events.new(status_event_params)
    event.occurred_at ||= Time.current

    if event.save
      load.update!(status: event.status)
      render json: event, status: :created
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def status_event_params
    params.require(:status_event).permit(:status, :occurred_at, :note)
  end
end
