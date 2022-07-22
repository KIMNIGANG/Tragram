module InstagramAuthHelper

  def get_media(token, *ids)
    # ------------------
    # private method
    # ------------------
    # input usertoken, media-ids
    # output response-bodies list

    ret = []
    ids.each do |id|
      #th = Thread.new do
      uri = URI.parse("https://graph.instagram.com/#{id}?fields=id,media_url,media_type&access_token=#{token}")
      puts "new uri #{uri} in get_media"
      res = Net::HTTP.get_response(uri)
      puts "#{res.class}: #{res}"
      unless res.is_a?(Net::HTTPOK) then
        puts "http-error in get_media"
        return redirect_to root_path
      end
      body = JSON.parse(res.body)
      ret.push(body)
    end

    puts "fin get_media--"
    return ret
  end

end
