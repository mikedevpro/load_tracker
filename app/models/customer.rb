class Customer < ApplicationRecord
  has_many :loads, dependent: :restrict_with_error
  validates :name, presence: true
end
