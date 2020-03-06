class ChangeColumnNameForCardToken < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :card_token, :stripe_cutomer_id
  end
end
