class CreateNews < ActiveRecord::Migration[5.2]
  def change
    create_table :news do |t|
      t.string :title
      t.text :full_text
      t.string :news_type
      t.text :post_url
      t.timestamps
    end
  end
end
