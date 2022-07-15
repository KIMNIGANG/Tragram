class Post < ApplicationRecord
  belongs_to :project
  has_many :post_images
  has_many :images, through: :post_images
<<<<<<< HEAD
  mount_uploader :image, ImageUploader
=======
  has_one :location, dependent: :destroy
>>>>>>> ea55840 (location-model, db作成. 登録済みlocationのpostへのdisplay)
end
