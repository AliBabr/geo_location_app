class AddTwilioTokenIntoUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :twilio_token, :string
  end
end
