class Conversation < ApplicationRecord
  validates :user_1, presence: true
  validates :user_2, presence: true

  has_many :messages, :dependent => :delete_all
end
