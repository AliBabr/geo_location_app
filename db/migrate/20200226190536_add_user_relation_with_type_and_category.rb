class AddUserRelationWithTypeAndCategory < ActiveRecord::Migration[5.2]
  def change
    add_reference(:users, :category, index: false)
    add_reference(:users, :leason_type, index: false)
  end
end
