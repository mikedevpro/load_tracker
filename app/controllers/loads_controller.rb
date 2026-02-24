class LoadsController < ApplicationController
  before_action :set_load, only: [:show, :update, :destroy]

  def index
    loads = Load.includes(:customer, :driver).order(created_at: :desc)

    loads = loads.where(status: params[:status]) if params[:status].present?
    loads = loads.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    loads = loads.where(driver_id: params[:driver_id]) if params[:driver_id].present?

    render json: loads.as_json(include: [:customer, :driver])
  end

  def show
    render json: @load.as_json(include: [:customer, :driver, :status_events])
  end

  def create
    load = Load.new(load_params)
    load.status ||= "booked"

    if load.save
      load.status_events.create!(
        status: load.status,
        occurred_at: Time.current,
        note: "Initial status"
      )

      render json: load, status: :created
    else
      render json: { errors: load.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    old_status = @load.status

    if @load.update(load_params)
      if @load.status != old_status
        @load.status_events.create!(
          status: @load.status,
          occurred_at: Time.current,
          note: "Status updated"
        )
      end

      render json: @load
    else
      render json: { errors: @load.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @load.destroy
    head :no_content
  end

  private

  def set_load
    @load = Load.find(params[:id])
  end

  def load_params
    params.require(:load).permit(
      :reference_number,
      :status,
      :pickup_date,
      :delivery_date,
      :origin_city,
      :dest_city,
      :rate,
      :customer_id,
      :driver_id
    )
  end
end