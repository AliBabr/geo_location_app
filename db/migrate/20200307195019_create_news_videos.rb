class CreateNewsVideos < ActiveRecord::Migration[5.2]
  def change
    create_table :news_videos do |t|

      t.timestamps
    end
  end
end
