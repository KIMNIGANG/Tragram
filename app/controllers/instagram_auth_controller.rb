class InstagramAuthController < ApplicationController
    require 'net/http'
    require 'uri'
    def index
      @redirect_uri=ENV['INST_REDIRECT_URI']
    end

    def create
      @code = params[:code]
    end

    def get_token   #最初のアクセストークンをもらってきて、ENVファイルの中に書き込む
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
        
        uri = URI("https://graph.instagram.com/access_token?grant_type=ig_exchange_token&client_secret=#{ENV['INST_CLIENT_SECRET']}&access_token=#{@response}")   #長期トークンに交換
        resp = Net::HTTP.get_response(uri).body
        resp = JSON.parse(resp)
        @token = resp["access_token"] 

        #accesstokenをファイルに書き込み（次回からはENVから読み込む）
        File.open("config/application.yml","a") { |f|
        f.write "USER_TOKEN: #{@token}\n"
        }

    end

    def get_media_test
        #userのidとusernameを取ってくる
        uri = URI("https://graph.instagram.com/me?fields=id,username&access_token=#{ENV['USER_TOKEN']}")
        resp = Net::HTTP.get_response(uri).body
        resp = JSON.parse(resp)
        @profile = resp["id"]   #resp["@@"]に変えることでuser@@をとれる (username or id or ...)

        #userのメディアidを取ってくる (写真のid)
        uri = URI("https://graph.instagram.com/me/media?fields=id,caption&access_token=#{ENV['USER_TOKEN']}")
        resp = Net::HTTP.get_response(uri).body
        resp = JSON.parse(resp)
        @media = resp["data"][1]["id"] 

        #写真のメディアデータを取ってくる
        uri = URI("https://graph.instagram.com/#{@media}?fields=id,media_url&access_token=#{ENV['USER_TOKEN']}")
        resp = Net::HTTP.get_response(uri).body
        resp = JSON.parse(resp)
        @mediaurl = resp["media_url"]

        uri = URI("https://graph.instagram.com/#{@media}/children?access_token=#{ENV['USER_TOKEN']}")
        resp = Net::HTTP.get_response(uri).body
        resp = JSON.parse(resp)
        @caption = resp["data"][3]["id"]
        @array_item = resp["data"]

        @mediaurl2 = []
        @array_item.each{|t|
          uri = URI("https://graph.instagram.com/#{t["id"]}?fields=id,media_url&access_token=#{ENV['USER_TOKEN']}")
          resp = Net::HTTP.get_response(uri).body
          resp = JSON.parse(resp)
          @mediaurl2.push(resp["media_url"])  #ここをまずどうするか工夫
        }

        # uri = URI("https://graph.instagram.com/#{@caption}?fields=id,media_url&access_token=#{ENV['USER_TOKEN']}")
        # resp = Net::HTTP.get_response(uri).body
        # resp = JSON.parse(resp)
        # @mediaurl2 = resp["media_url"]

        # uri = URI("https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=#{ENV['USER_TOKEN']}")
        # resp = Net::HTTP.get_response(uri).body
        # resp = JSON.parse(resp)
        # @refreshed = resp["access_token"]
        # File.open("config/application.yml","r+") { |f|
        #   f.write "USER_TOKEN: #{@refreshed}"
        # } #access tokenの期限を延長する
    end

end