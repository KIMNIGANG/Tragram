class ChangeUserProjectsToUserProject < ActiveRecord::Migration[6.1]
  def change
    rename_table :user_projects, :user_project
  end
end
