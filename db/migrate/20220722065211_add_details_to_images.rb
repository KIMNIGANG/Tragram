class AddDetailsToImages < ActiveRecord::Migration[6.1]
  def change
    add_column :images, :instagram_id, :integer
  end
end
