class Image < ApplicationRecord
  belongs_to :posts
  mount_uploader :image, ImageUploader
end
