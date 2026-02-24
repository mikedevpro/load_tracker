class DashboardController < ApplicationController
  ACTIVE_STATUSES = %w[booked dispatched picked_up in_transit].freeze

  def show
    loads = Load.all

    total_loads = loads.count
    active_loads = loads.where(status: ACTIVE_STATUSES).count
    delivered = loads.where(status: "delivered")
    delivered_count = delivered.count

    revenue_total = loads.sum(:rate).to_f
    revenue_delivered = delivered.sum(:rate).to_f

    # "On-time" definition (simple + explainable):
    # delivered_on_or_before_delivery_date
    # If delivery_date is nil, it can't be on-time
    on_time_count = delivered.where.not(delivery_date: nil)
                             .where("delivery_date >= pickup_date") # sanity
                             .count

    on_time_pct = delivered_count.zero? ? 0.0 : ((on_time_count.to_f / delivered_count) * 100.0).round(1)

    # Avg transit days for delivered loads with dates
    avg_transit_days =
      delivered.where.not(delivery_date: nil, pickup_date: nil)
               .average("julianday(delivery_date) - julianday(pickup_date)")

    avg_transit_days = avg_transit_days ? avg_transit_days.to_f.round(2) : 0.0

    # Top customers by revenue (all loads)
    top_customers = Customer
      .joins(:loads)
      .select("customers.id, customers.name, SUM(loads.rate) AS revenue")
      .group("customers.id")
      .order("revenue DESC")
      .limit(5)
      .map { |c| { id: c.id, name: c.name, revenue: c.revenue.to_f } }

    # Status breakdown
    by_status = Load.group(:status).count

    render json: {
      totals: {
        loads: total_loads,
        active_loads: active_loads,
        delivered: delivered_count
      },
      revenue: {
        total: revenue_total,
        delivered: revenue_delivered
      },
      performance: {
        on_time_pct: on_time_pct,
        avg_transit_days: avg_transit_days
      },
      breakdowns: {
        by_status: by_status,
        top_customers: top_customers
      }
    }
  end
end
