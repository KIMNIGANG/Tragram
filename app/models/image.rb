class Image < ApplicationRecord
  has_many :post_images
  has_many :posts, through: :post_images
end
