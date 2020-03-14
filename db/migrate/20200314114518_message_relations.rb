class MessageRelations < ActiveRecord::Migration[5.2]
  def change
    add_reference(:messages, :conversation, index: false)
  end
end
