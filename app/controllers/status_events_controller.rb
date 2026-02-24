class StatusEventsController < ApplicationController
  def index
    load = Load.find(params[:load_id])
    render json: load.status_events.order(occurred_at: :desc)
  end

  def create
    load = Load.find(params[:load_id])

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