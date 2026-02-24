class Load < ApplicationRecord
  belongs_to :customer
  belongs_to :driver, optional: true
  has_many :status_events, dependent: :destroy

  STATUSES %w[
    booked
    dispatched
    picked_up
    in_transit
    delivered
    canceled
    ].freeze

    validates :reference_number, presence: true, uniqueness: true
    validates :status, inclusion: { in: STATUES }, allow_nil: true
    validates :pickup_date, presence: true
    validates :origin_city, presence: true
    validates :dest_city, presence: true
    validates :rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
