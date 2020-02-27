class LessonRelations < ActiveRecord::Migration[5.2]
  def change
    add_reference(:lessons, :category, index: false)
    add_reference(:lessons, :leason_type, index: false)
    add_reference(:lessons, :user, index: false)
  end
end
