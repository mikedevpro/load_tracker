class LoadsController < ApplicationController
  before_action :require_dispatcher!, only: [ :create, :update, :destroy ]
  before_action :set_load, only: [ :show, :update, :destroy ]

  def index
    if current_user.role == "driver" && params[:driver_id].present? && params[:driver_id].to_i != current_user.driver_id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    loads = Load.includes(:customer, :driver).order(created_at: :desc)

    if current_user.role == "driver"
      loads = loads.where(driver_id: current_user.driver_id)
    end

    # Exact-match filters
    loads = loads.where(status: params[:status]) if params[:status].present?
    loads = loads.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    loads = loads.where(driver_id: params[:driver_id]) if params[:driver_id].present?

    # Pickup date range
    loads = loads.where("pickup_date >= ?", params[:pickup_from]) if params[:pickup_from].present?
    loads = loads.where("pickup_date <= ?", params[:pickup_to]) if params[:pickup_to].present?

    # Rate range
    loads = loads.where("rate >= ?", params[:min_rate]) if params[:min_rate].present?
    loads = loads.where("rate <= ?", params[:max_rate]) if params[:max_rate].present?

    # Text search (reference/origin/destination)
    if params[:q].present?
      q = "%#{params[:q]}%"
      loads = loads.where(
        "reference_number LIKE ? OR origin_city LIKE ? OR dest_city LIKE ?",
        q, q, q
    )
    end

  render json: loads.as_json(include: [ :customer, :driver ])
  end

  def show
    if current_user.role == "driver" && @load.driver_id != current_user.driver_id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    render json: @load.as_json(include: [ :customer, :driver, :status_events ])
  end

  def create
    load = Load.new(load_params)
    load.status ||= "booked"

    if current_user.role == "driver" && load.driver_id != current_user.driver_id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

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

  def active
    active_statuses = %w[booked dispatched picked_up in_transit]
    loads = Load.includes(:customer, :driver)
                .where(status: active_statuses)
                .order(pickup_date: :desc)

    render json: loads.as_json(include: [ :customer, :driver ])
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
