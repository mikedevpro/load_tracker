class CustomersController < ApplicationController
  before_action :require_dispatcher!
  def index
    render json: Customer.order(:name)
  end

  def show
    render json: Customer.find(params[:id])
  end

  def create
    customer = Customer.new(customer_params)
    if customer.save
      render json: customer, status: :created
    else
      render json: { errors: customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    customer = Customer.find(params[:id])
    if customer.update(customer_params)
      render json: customer
    else
      render json: { errors: customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    customer = Customer.find(params[:id])
    if customer.destroy
      head :no_content
    else
      render json: { errors: customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def customer_params
    params.require(:customer).permit(:name)
  end
end
