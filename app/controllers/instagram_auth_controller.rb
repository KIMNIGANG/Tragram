require 'uri'

class InstagramAuthController < ApplicationController
    require 'net/http'
    require 'uri'
    def index
      @redirect_uri=ENV['redirect_uri']
    end

    def create
      @code = params[:code]
    end

    def get_token
      uri = URI.parse('https://api.instagram.com/oauth/access_token')
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({
        "client_id" => "555005406003631",
        "client_secret" => "3a993bf3425dda372bbb5cd264b39bf4",
        "grant_type" => "authorization_code",
        "redirect_uri" => "https://localhost:3001/authpass/",
        "code" => params[:code],
        })    
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        res = http.request(request)
      @response = res.body  #この中にaccesstokenが入っている（"{\"access_token\": \"IGQVJW・・・EMXR93\", \"user_id\": 1784・・・3807}")
      end
  end
end