class GoogleMapController < ApplicationController
  require 'net/http'
  require 'uri'
  def index
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

end
