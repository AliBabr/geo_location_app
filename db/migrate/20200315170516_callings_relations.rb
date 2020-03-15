class CallingsRelations < ActiveRecord::Migration[5.2]
  def change
    add_reference(:callings, :booking, index: false)
  end
end
