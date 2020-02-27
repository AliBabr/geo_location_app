class ChangeUserIdTypeForLesson < ActiveRecord::Migration[5.2]
  def change
    change_column :lessons, :user_id, :string
  end
end
