class CreateInstagramtokens < ActiveRecord::Migration[6.1]
  def change
    create_table :instagramtokens do |t|
      t.integer :user_id
      t.string :token
      t.timestamp :expires_at

      t.timestamps
    end
  end
end
