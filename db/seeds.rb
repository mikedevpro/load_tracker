# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

puts "Seeding Load Tracker..."

StatusEvent.delete_all
Load.delete_all
User.delete_all
Driver.delete_all
Customer.delete_all

customers = [
  "Acme Freight",
  "Sunset Logistics",
  "Desert Supply Co",
  "Mountain Retail",
  "Northstar Distribution"
].map { |name| Customer.create!(name: name) }

drivers = [
  { name: "Mike Nobles", phone: "555-0101" },
  { name: "Jordan Lee", phone: "555-0102" },
  { name: "Sam Patel", phone: "555-0103" },
  { name: "Taylor Cruz", phone: "555-0104" }
].map { |d| Driver.create!(d) }

def days_ago(n)
  Date.today - n
end

def rand_city
  [
    "Los Angeles, CA", "Phoenix, AZ", "Denver, CO", "Albuquerque, NM",
    "Las Vegas, NV", "Salt Lake City, UT", "Dallas, TX", "Kansas City, MO"
  ].sample
end

statuses = %w[booked dispatched picked_up in_transit delivered canceled]

# Create ~25 loads with a realistic spread
25.times do |i|
  customer = customers.sample
  driver = [ drivers.sample, nil ].sample # sometimes unassigned

  pickup = days_ago(rand(0..14))
  delivery = pickup + rand(1..4)

  status = statuses.sample
  # skew toward active + delivered
  status = %w[in_transit delivered booked dispatched].sample if rand < 0.7

  load = Load.create!(
    reference_number: format("LD-%04d", 1000 + i),
    status: status,
    pickup_date: pickup,
    delivery_date: (status == "delivered" ? delivery : nil),
    origin_city: rand_city,
    dest_city: rand_city,
    rate: [ 950, 1200, 1450, 1600, 1800, 2100, 2500 ].sample,
    customer: customer,
    driver: driver
  )

  # Build a believable status history
  timeline = case status
  when "booked"      then [ "booked" ]
  when "dispatched"  then [ "booked", "dispatched" ]
  when "picked_up"   then [ "booked", "dispatched", "picked_up" ]
  when "in_transit"  then [ "booked", "dispatched", "picked_up", "in_transit" ]
  when "delivered"   then [ "booked", "dispatched", "picked_up", "in_transit", "delivered" ]
  when "canceled"    then [ "booked", "canceled" ]
  else [ status ]
  end

  timeline.each_with_index do |st, idx|
    occurred_at = (load.pickup_date.to_time + (idx * 4).hours)
    load.status_events.create!(
      status: st,
      occurred_at: occurred_at,
      note: case st
            when "booked" then "Booked by dispatcher"
            when "dispatched" then "Driver assigned / dispatched"
            when "picked_up" then "Picked up at shipper"
            when "in_transit" then "Rolling"
            when "delivered" then "Delivered + POD received"
            when "canceled" then "Canceled by customer"
            else "Status update"
            end
    )
  end
end

User.delete_all

User.create!(
  email: "dispatcher@test.com",
  password: "password",
  password_confirmation: "password",
  role: "dispatcher"
)

User.create!(
  email: "driver@test.com",
  password: "password",
  password_confirmation: "password",
  role: "driver",
  driver: Driver.first
)

puts "✅ Users:"
puts "Dispatcher login: dispatcher@test.com / password"
puts "Driver login: driver@test.com / password"

puts "✅ Seed complete: #{Customer.count} customers, #{Driver.count} drivers, #{Load.count} loads, #{StatusEvent.count} status events."
