class AddCardTokenIntoUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :card_token, :string
    add_column :users, :connected_account_id, :string
  end
end
