class InstagramAuthController < ApplicationController
    require 'net/http'
    require 'uri'
    require 'yaml'
    require 'time'

    # /instagram get
    def index
      # /oauth/へのurlをuserに踏ませる
      # token持ってない時は、
      if !current_user then
        flash[:caution] = 'user doesnt exist'
        redirect_to root_path
      end
      token = current_user.instagramtoken ||= nil
      if token then
        @days_left = (token.expires_at - Time.now)/(60*60*24)
      end
      redirect_uri = ENV['INST_REDIRECT_URI']
      client_id = ENV['INST_CLIENT_ID']
      link = URI.parse("https://api.instagram.com/oauth/authorize")
      params = { "client_id" => client_id, "redirect_uri" => redirect_uri, "scope" => "user_profile,user_media", "response_type" => "code"}
      link.query = URI.encode_www_form(params)
      @link = link.to_s
      # instagram -> get_tokenへとリダイレクトされる
    end


    def get_token
      # '/authpass'
      # redirect from instagram with code

      # short term
      uri = URI.parse('https://api.instagram.com/oauth/access_token')
      res = Net::HTTP.post_form(uri,
      {
        "client_id" => ENV['INST_CLIENT_ID'],
        "client_secret" => ENV['INST_CLIENT_SECRET'],
        "grant_type" => "authorization_code",
        "redirect_uri" => ENV['INST_REDIRECT_URI'],
        "code" => params[:code]
      })

      res = JSON.parse(res.body)
      short_token = res["access_token"]


      # long term
      puts "--long term start--"
      uri = URI.parse("https://graph.instagram.com/access_token")
      p = {"grant_type" => "ig_exchange_token", "client_secret" => ENV['INST_CLIENT_SECRET'], "access_token" => short_token}
      uri.query = URI.encode_www_form(p)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl= true
      res = Net::HTTP.get_response(uri)
      if res.code != 200 then
        puts "http error--"
        puts res.code
        puts "------------"
      end
      res = JSON.parse(res.body)
      expires_in = res['expires_in']
      puts "in---"
      puts expires_in
      expires_at = Time.now + expires_in
      puts expires_at
      long_token = res["access_token"]
      puts "--long term token fetched--"



      # user tokenの書き換え
      if !current_user.instagramtoken then
        puts "create new instagramtoken instance=========="
        token_instance = Instagramtoken.create(token: long_token, expires_at: expires_at)
        current_user.instagramtoken = token_instance
      #else
      #  puts "update instagramtoken instance===="
      #  current_user.instagramtoken.update(token: long_token, expires_at: expires_at)
      end

      print "-- gettoken fin -"
      if session[:post_url].present?
        redirect_to session[:post_url]
        session.delete(:post_url)
      else
        redirect_to root_path
      end

    end

    def token_exchange()
      if !current_user.instagramtoken then
        flash[:caution] = 'you dont have a instagramtoken'
        return redirect_to root_path
      end

      token = current_user.instagramtoken.token

      uri = URI.parse("https://graph.instagram.com/refresh_access_token")
      p = {"grant_type" => "ig_refresh_token", "access_token" => token}
      uri.query = URI.encode_www_form(p)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      res = Net::HTTP.get_response(uri)
      if res.code != 200 then
        puts "http error--"
        puts res.code
        puts "------------"
      end
      res = JSON.parse(res.body)
      expires_in = res['expires_in']
      expires_at = Time.now + expires_in

      long_token = res["access_token"]
      puts "--long term token fetched--"

      current_user.instagramtoken.update(token: long_token, expires_at: expires_at)
      puts "token exchanged--"
      redirect_to "/instagram"

    end



    def get_album(token, id)
      # private
      # I token, media_id(of an album)
      # O list of media from a album
      puts "get_album start ---"
      media_ls = []
      uri = URI("https://graph.instagram.com/#{id}/children?fields=media_url,id&access_token=#{token}")
      res = Net::HTTP.get_response(uri)
      puts res

      unless res.is_a?(Net::HTTPOK) then
        puts "get_aubum http error---"
        flash[:alert] = 'エラー　ホームに戻ります'
        return redirect_to root_path
      end

      body = JSON.parse(res.body)
      puts "body: #{body}"

      ids = []
      body["data"].each do |media|
        ids.push(media["id"])
      end

      album = []
      res = get_media(token, *ids)
      res.each do |media|
        album.push( { "url" => media['media_url'], "media_type" => media['media_type'], "id" => media['id'] } )
      end
      return album
    end


    def show_image
      # insert_imageからpostにリダイレクトする用に使用
      # insert actionへのformにこれを仕込む
      #
      #
      # @albums = [
      #            album [
      #              media { media_type: hoge, url: hoge }]]
      post_url = "posts/#{@post_id}"

      @post_id = params[:id]

      unless current_user then
        flash[:alert] = 'ユーザー認識ができません'
        redirect_to post_url
      end

      unless current_user.instagramtoken then
        flash[:alert] = 'instagramアカウントを連携していません'
        redirect_to '/instagram' and return
      end

      token = current_user.instagramtoken.token
      @albums = []

      # get ids from "me"
      uri = URI.parse("https://graph.instagram.com/me/media?fields=id,media_url,media_type&access_token=#{token}")
      puts "fetching from \"me\"..... #{uri}"

      res = Net::HTTP.get_response(uri)
      unless res.is_a?(Net::HTTPOK) then
        puts "http error in get_me"
        redirect_to  and return
      end
      begin
        res = JSON.parse(res.body)
        puts "res--"
        puts res
      rescue => e
        puts e
      end
      media = res["data"]
      puts "media--"
      puts media
      # res = {data: [{id: hoge}, {id: foo},,,]}

      if media == nil then
        flash[:danger] = 'no media found'
        return redirect_to root_path
      end
      # get ids from "me" FIN


      media.each do |m|
        if m['media_type'] == 'CAROUSEL_ALBUM' then
          puts "get album"
          @albums.push(get_album(token, m["id"]))
        else
          case m['media_type']
          when 'IMAGE' then
            @albums.push( [{ "url" => m['media_url'], "media_type" => "IMAGE", "id" => m['id'] }] )
          when 'VIDEO' then
            @albums.push( [{ "url" => m['media_url'], "media_type" => "VIDEO", "id" => m['id'] }] )
          end
        end
      end

      puts "albums----"
      pp @albums
    end

    # 画像urlをそのpostのテーブルに追加
    # 画像urlのリストをquerystringとして受け取ることにする(とりあえず)
    # image-tableへは、show_imageのviewで行うことにする
    # ここでは、postとimageの関係性を作るだけ

    def insert_image_to_post
      if !current_user then
        flash[:danger] = 'no user'
        return redirect_to root_path
      end

      post = Post.find_by(id: params[:id].to_i)
      if !post then
        puts "no posts"
        flash[:danger] = 'this post doesn\'t exist'
        return redirect_to root_path
      end

      params[:media].each do |url_type|
        out = url_type.split(",")
        img = Image.create(url: out[0], media_type: out[1], instagram_id: out[2].to_i)
        post.images << img
      end

      ## postへのリダイレクト
      redirect_to post_path(id: post.id)
    end

end
