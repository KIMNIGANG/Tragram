class Project < ApplicationRecord
  has_many: posts
  has_many: members, source: :user


end
