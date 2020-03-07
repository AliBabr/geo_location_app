class NewsRelation < ActiveRecord::Migration[5.2]
  def change
    add_reference(:news_videos, :news, index: false)
  end
end
