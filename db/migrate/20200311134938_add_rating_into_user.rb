class AddRatingIntoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :rating, :float
  end
end
