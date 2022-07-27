class CreateUserProject < ActiveRecord::Migration[6.1]
  def change
    create_table :user_project do |t|
      t.integer :user_id
      t.integer :project_id
      t.timestamps
    end
  end
end
