class Post < ApplicationRecord
  belongs_to :project
  has_many :images
end
