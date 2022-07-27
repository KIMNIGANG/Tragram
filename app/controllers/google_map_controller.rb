class GoogleMapController < ApplicationController
  require 'net/http'
  require 'uri'
  def index
<<<<<<< HEAD
    require "uri"
    require "net/http"

    url = URI("https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=Mujaki&inputtype=textquery&fields=formatted_address%2Cname%2Crating%2Copening_hours%2Cgeometry&key=#{ENV["GOOGLE_MAP_API_KEY"]}")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)

    @response = https.request(request).body
    @response = JSON.parse(@response)
    #@lat = @response["candidates"][0]["geometry"]["location"]["lat"]
    #@lng = @response["candidates"][0]["geometry"]["location"]["lng"]
  end

  def map

  end
=======
    #userのメディアidを取ってくる (写真のid)
    uri = URI("https://graph.instagram.com/me/media?fields=id,caption&access_token=#{ENV['USER_TOKEN']}")
    resp = Net::HTTP.get_response(uri).body
    resp = JSON.parse(resp)
    @media = resp["data"][1]["id"] 
  
    uri = URI("https://graph.instagram.com/#{@media}/children?access_token=#{ENV['USER_TOKEN']}")
    resp = Net::HTTP.get_response(uri).body
    resp = JSON.parse(resp)
    @array_item = resp["data"]

    #location id　をもらってくる    エラー発生中
    uri = URI("https://graph.instagram.com/#{@media}/fields=location?access_token=#{ENV['USER_TOKEN']}")
    resp = Net::HTTP.get_response(uri).body
    # resp = JSON.parse(resp)
    @location = resp
    
    @mediaurl_v = []  #videoのurlが入る配列
    @mediaurl_i = []  #imgのurlが入る配列
    @array_item.each{|t|
      uri = URI("https://graph.instagram.com/#{t["id"]}?fields=id,media_url&access_token=#{ENV['USER_TOKEN']}")
      resp = Net::HTTP.get_response(uri).body
      resp = JSON.parse(resp)
      media_url = resp["media_url"]
      if media_url[8] == "v"
        @mediaurl_v.push(resp["media_url"])  
      else
        @mediaurl_i.push(resp["media_url"])
      end
    }
  end

>>>>>>> d83dc1a (map基礎)
end
