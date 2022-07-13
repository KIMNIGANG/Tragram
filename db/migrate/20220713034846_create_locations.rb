class CreateLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :locations do |t|

      t.float :lat
      t.float :lng
      t.string :name
      t.integer :post_id

      t.timestamps
    end
  end
end
