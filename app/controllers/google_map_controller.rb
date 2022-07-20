class GoogleMapController < ApplicationController
  require 'net/http'
  require 'uri'
  def index
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
end
