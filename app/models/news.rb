class News < ApplicationRecord
  has_one_attached :image
  has_one :news_video
end
