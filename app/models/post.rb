class Post < ApplicationRecord
  belongs_to :project
  has_many :post_images
  has_many :images, through: :post_images
  mount_uploader :image, ImageUploader
end
