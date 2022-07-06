class User < ApplicationRecord
  has_many :user_projects
  has_many :projects, through: :user_projects
  has_one :instagramtoken

  class << self
    def find_or_create_from_auth_hash(auth_hash)
      user_params = user_params_from_auth_hash(auth_hash)
      find_or_create_by(name: user_params[:name]) do |user|
        user.update(user_params)
      end
    end

    private

    def user_params_from_auth_hash(auth_hash)
      {
        name: auth_hash.info.name
      }
    end
  end
end
