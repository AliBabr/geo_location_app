class AddFcmTokenIntoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :fcm_token, :string
  end
end
