class Project < ApplicationRecord
  has_many :users ,through: :user_projects
  has_many :posts, dependent: :destroy
  has_many :user_projects
end


