require 'uri'

class InstagramAuthController < ApplicationController
    require 'net/http'
    require 'uri'
    def index
    end

    # リダイレクト先
    # もらったcodeをpush
    
    def auth_pass
      code = params[:code]
      uri = URI('https://api.instagram.com/oauth/access_token')
      uri.query = URI.encode_www_form({
      client_id: '555005406003631', client_secret: '3a993bf3425dda372bbb5cd264b39bf4', grant_type: 'authorization_code' , redirect_uri: 'https://f9fb-133-51-117-147.jp.ngrok.io/authpass', code: code
      })

      request = Net::HTTP::Post.new(uri)

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
      end
    end

    # access_tokenもらう
    def auth_get_token
      token = params[:access_token]
      user_id = params[:user_id]
    end
  end