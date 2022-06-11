class Post < ApplicationRecord
  belongs_to :projects
  has_many :images
end
