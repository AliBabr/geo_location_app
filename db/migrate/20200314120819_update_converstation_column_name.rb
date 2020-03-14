class UpdateConverstationColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :conversations, :sender_id, :user_1
    rename_column :conversations, :receiver_id, :user_2
    add_column :messages, :sender_id, :string
    add_column :messages, :receiver_id, :string
  end
end
