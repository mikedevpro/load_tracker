class Driver < ApplicationRecord
  has_many :loads, dependent: :nullify
  validates :name, presence: true
end
