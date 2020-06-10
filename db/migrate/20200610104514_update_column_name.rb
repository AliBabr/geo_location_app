class UpdateColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :twilio_token, :video_calling_id
  end
end
