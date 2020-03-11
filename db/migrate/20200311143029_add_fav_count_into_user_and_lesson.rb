class AddFavCountIntoUserAndLesson < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :fav_count, :integer
    add_column :lessons, :fav_count, :integer
  end
end
