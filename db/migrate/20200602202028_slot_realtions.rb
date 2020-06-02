class SlotRealtions < ActiveRecord::Migration[5.2]
  def change
    add_reference(:slots, :user, index: false)
  end
end
