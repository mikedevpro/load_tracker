class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :driver, optional: true

  ROLES = %w[dispatcher driver].freeze

  validates :role, presence: true, inclusion: { in: ROLES }
end
