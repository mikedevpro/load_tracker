class StatusEvent < ApplicationRecord
  belongs_to :load
  validates :status, presence: true
  validates :occurred_at, presence: true
end
