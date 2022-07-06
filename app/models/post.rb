class Post < ApplicationRecord
  belongs_to :project
  has_one :post_image
  has_many :images, through: :post_image
end
