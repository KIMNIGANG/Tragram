class Project < ApplicationRecord
  has_many: posts
  # 名
  has_many: users, through: :user


end

