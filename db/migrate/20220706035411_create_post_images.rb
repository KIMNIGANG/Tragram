class CreatePostImages < ActiveRecord::Migration[6.1]
  def change
    create_table :post_images do |t|

      t.integer :image_id
      t.integer :post_id
      t.timestamps
    end
  end
end
