require 'uri'

class InstagramAuthController < ApplicationController
    def index
    end

    # リダイレクト先
    # もらったcodeをpush
    
    def auth_pass
      code = params[:code]
      uri = URI('https://api.instagram.com/oauth/access_token')
      uri.query = URI.encode_www_form({
      client_id: '555005406003631', client_secret: '3a993bf3425dda372bbb5cd264b39bf4', grant_type: 'authorization_code' , redirect_uri: 'https://github.com/KIMNIGANG/Tragram', code: code
      })

    end

    # access_tokenもらう
    def auth_get_token
      token = params[:access_token]
      user_id = params[:user_id]
    end
  end