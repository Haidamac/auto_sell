require 'securerandom'

class User < ApplicationRecord
  include Userable

  has_many :cars, dependent: :destroy

  has_secure_password

  PASSWORD_RESET_EXPIRATION = 4.hours
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /\A
    (?=.*\d)           # At least one digit
    (?=.*[a-z])        # At least one lowercase letter
    (?=.*[A-Z])        # At least one uppercase letter
    (?=.*[[:^alnum:]]) # At least one symbol
    [[:print:]]{8,}    # At least 8 printable characters
  \z/x

  validates :email, presence: true, length: { minimum: 5, maximum: 255 }, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 8, maximum: 255 }, format: { with: VALID_PASSWORD_REGEX },
                       on: :create
  validates :name, presence: true, length: { minimum: 3, maximum: 50 }

  enum role: %i[participant admin]

  scope :role_filter, ->(role) { where(role:) }
end
