class AddRatingRelation < ActiveRecord::Migration[5.2]
  def change
    add_reference(:ratings, :booking, index: false)
  end
end
