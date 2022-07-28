class Post < ApplicationRecord
  belongs_to :project
  has_many :post_images

  has_many :images, through: :post_images
  has_one :location, dependent: :destroy

  belongs_to :user
end
