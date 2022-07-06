class InstagramAuthController < ApplicationController
    require 'net/http'
    require 'uri'
    require 'yaml'
    require 'time'

    def auth
      # /oauth/へのurlをuserに踏ませる
      # token持ってない時は、
      if !current_user then
        flash[:caution] = 'user doesnt exist'
        redirect_to root_path
      end
      token = current_user.instagramtoken
      if token != nil then
        @expires_in = token.expires_in / 60 * 60 * 24
      end
      @redirect_uri = ENV['INST_REDIRECT_URI']
      @client_id = ENV['INST_CLIENT_ID']

      # instagram -> get_tokenへとリダイレクトされる
    end


    def get_token
      # '/authpass'
      # redirect from instagram with code

      # short term
      uri = URI.parse('https://api.instagram.com/oauth/access_token')
      res = Net::HTTP.post_form(uri,
      { "client_id" => ENV['INST_CLIENT_ID'],
        "client_secret" => ENV['INST_CLIENT_SECRET'],
        "grant_type" => "authorization_code",
        "redirect_uri" => ENV['INST_REDIRECT_URI'],
        "code" => params[:code]
      })

      res = JSON.parse(res.body)
      short_token = res["access_token"]

      
      # long term
      uri = URI.parse("https://graph.instagram.com/access_token")
      p = {"grant_type" => "ig_exchange_token", "client_secret" => ENV['INST_CLIENT_SECRET'], "access_token" => short_token}
      uri.query = URI.encode_www_form(p)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Get.new(uri.request_uri)
      res = http.request(req)
      res = JSON.parse(res.body)
      puts "res --"
      puts res
      expires_in = res['expires_in']
      long_token = res["access_token"]
      puts "result----"
      puts expires_in
      puts long_token


      # user tokenの書き換え
      if !current_user.instagramtoken then
        puts "create new instagramtoken instance=========="
        token_instance = Instagramtoken.create(token: long_token, expires_in: expires_in)
        current_user.instagramtoken = token_instance
      else
        puts "update instagramtoken instance"
        current_user.instagramtoken.update(token: long_token, expires_in: expires_in)
      end

      print "fin gettoken-------------"
      redirect_to root_path

    end

    def get_media_url(media_id, token)
      # ------------------
      # private method
      # ------------------
      uri = URI("https://graph.instagram.com/#{media_id}?fields=media_url&access_token=#{token}")
      begin
        resp = Net::HTTP.get_response(uri).body
        resp = JSON.parse(resp)
      rescue => e
        puts e
      end
      return resp["media_url"]
    end

    def show_image
      # insert_imageからpostにリダイレクトする用に使用
      # insert actionへのformにこれを仕込む
      if !current_user then
        flash[:caution] = 'not valid user'
        redirect_to root_path
      end

      token = current_user.instagramtoken.token
      @post_id = params[:id]
      @image_urls = Hash.new
      @video_urls = Hash.new

      # get media ids
      uri = URI("https://graph.instagram.com/me/media?fields=id&access_token=#{token}")
      puts "fetching....."
      begin
        "parsing-----"
        res = Net::HTTP.get_response(uri).body
        res = JSON.parse(res)
      rescue => e
        puts e
      end
      media = res["data"]
      # res = {data: [{id: hoge}, {id: foo},,,]}

      if media == nil then
        flash[:danger] = 'no media found'
        return redirect_to root_path
      end

      # get media urls
      # 完全版は、sliceを消す
      @media_ls = []
      #media.slice(0,4).each do |m|
      media.each do |m|
        uri = URI("https://graph.instagram.com/#{m["id"]}?fields=id,media_url,media_type&access_token=#{token}")
        begin
          res = Net::HTTP.get_response(uri).body
          @media_ls.push(JSON.parse(res))
        rescue => e
          puts e
        end
      end
      pp @media_ls

      # albumはあとで考えよう
      #media_ls.each do |media|
      #  if media['media_type'] == 'CAROUSEL_ALBUM' then

      #  end
      #end

      

        # albumの場合は、各写真や動画に応じてurlを取得する必要がある
     #   if res["media_type"] == "CAROUSEL_ALBUM" then
     #     uri = URI("https://graph.instagram.com/#{res["id"]}/children?access_token=#{token}")
     #     begin
     #       in_res = Net::HTTP.get_response(uri).body
     #       in_res = JSON.parse(res)
     #       data = in_res["data"]
     #     rescue => e
     #       puts e
     #     end
     #     data.each{|d| @image_urls[res["id"]] = get_media_url(d["id"], token)}
     #   else
     #     # non album
     #     @image_urls[res["id"]] = res["media_url"]
     #   end
     # end

    end

    # 画像urlをそのpostのテーブルに追加
    # 画像urlのリストをquerystringとして受け取ることにする(とりあえず)
    # image-tableへは、show_imageのviewで行うことにする
    # ここでは、postとimageの関係性を作るだけ
    def insert_image_to_post
      post = Post.find_by(id: params[:id])
      params[:image_list].each do |url, state|
        if state == "1" then
          post.images.create(url: url)
        end
      end
      # postへのリダイレクト
      redirect_to controller: :post, action: :show, id: post.id
    end

end
