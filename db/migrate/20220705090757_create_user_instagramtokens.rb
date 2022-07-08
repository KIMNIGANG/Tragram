class CreateUserInstagramtokens < ActiveRecord::Migration[6.1]
  def change
    create_table :user_instagramtokens do |t|

      t.integer :user_id
      t.integer :instagramtoken_id
      t.timestamps
    end
  end
end
