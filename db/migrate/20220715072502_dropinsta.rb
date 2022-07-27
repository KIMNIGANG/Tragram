class Dropinsta < ActiveRecord::Migration[6.1]
  def change
    drop_table :instagramtokens
  end
end
