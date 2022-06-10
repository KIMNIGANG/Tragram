class InstagramAuthController < ApplicationController
    require 'net/http'
    require 'uri'
    def index
      @redirect_uri=ENV['INST_REDIRECT_URI']
    end

    def create
      @code = params[:code]
    end

    def get_token
      uri = URI.parse('https://api.instagram.com/oauth/access_token')
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data({
        "client_id" => "#{ENV['INST_CLIENT_ID']}",
        "client_secret" => "#{ENV['INST_CLIENT_SECRET']}",
        "grant_type" => "authorization_code",
        "redirect_uri" => "#{ENV['INST_REDIRECT_URI']}",
        "code" => params[:code],
        })    
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        res = http.request(request).body
      res = JSON.parse(res)
      @response = res["access_token"] #この中にaccesstokenが入っている（"{\"access_token\": \"IGQVJW・・・EMXR93\", \"user_id\": 1784・・・3807}")
      end
  end
end