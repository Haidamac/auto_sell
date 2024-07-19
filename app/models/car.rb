class Car < ApplicationRecord

  belongs_to :user
  has_many_attached :images

  enum status: %i[pending rejected approved]

  scope :filter_by_participant, ->(user) { where(user_id: user) }
  scope :filter_by_status, ->(status) { where(status:) }


end
