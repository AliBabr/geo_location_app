class Message < ApplicationRecord
  has_one_attached :media
  validates :sender_id, presence: true
  validates :receiver_id, presence: true

  belongs_to :conversation
  enum status: {
    "read" => 1,
    "unread" => 2,
  }
end
