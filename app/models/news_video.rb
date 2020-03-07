class NewsVideo < ApplicationRecord
  has_one_attached :video
  belongs_to :news
end
