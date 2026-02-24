class DriversController < ApplicationController
  def index
    render json: Driver.order(:name)
  end

  def show
    render json: Driver.find(params[:id])
  end

  def create
    driver = Driver.new(driver_params)
    if driver.save
      render json: driver, status: :created
    else
      render json: { errors: driver.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    driver = Driver.find(params[:id])
    if driver.update(driver_params)
      render json: driver
    else
      render json: { errors: driver.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    driver = Driver.find(params[:id])
    if driver.destroy
      head :no_content
    else
      render json: { errors: driver.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def driver_params
    params.require(:driver).permit(:name, :phone)
  end
end
