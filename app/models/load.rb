class Load < ApplicationRecord
  STATUSES = %w[
    booked
    dispatched
    picked_up
    in_transit
    delivered
    canceled
  ].freeze

  belongs_to :customer
  belongs_to :driver, optional: true
  has_many :status_events, dependent: :destroy

  validates :reference_number, presence: true
  validates :pickup_date, presence: true
  validates :origin_city, :dest_city, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
end
