class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  belongs_to :driver, optional: true

  ROLES = %w[dispatcher driver].freeze

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: :password_required?
  validates :role, presence: true, inclusion: { in: ROLES }
end
