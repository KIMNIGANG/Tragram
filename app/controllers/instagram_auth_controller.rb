class InstagramAuthController < ApplicationController
    require 'net/http'
    require 'uri'
    require 'yaml'

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
        # 6/29 これは、一人一回でよさそうだから例外処理いらない？
      #   それともスコープの問題か？　respが空でエラーになった
        # それとも環境変数に基づいて処理の必要有無を判断するか
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          res = http.request(request).body
          res = JSON.parse(res)
          @response = res["access_token"]
          # この中にaccesstokenが入っている
          #（"{\"access_token\": \"IGQVJW・・・EMXR93\", \"user_id\": 1784・・・3807}")
          print "res------------"
          print res
        end

      uri = URI("https://graph.instagram.com/access_token?grant_type=ig_exchange_token&client_secret=#{ENV['INST_CLIENT_SECRET']}&access_token=#{@response}")   #長期トークンに交換
      resp = Net::HTTP.get_response(uri).body
      resp = JSON.parse(resp)
      @token = resp["access_token"]


      begin
        data = open('config/application.yml', 'r'){|f| YAML.load(f)}
        data["USER_TOKEN"] = @token
        YAML.dump(data, File.open('config/application.yml', 'w'))
      rescue => e
        e.response
      end

      print "fin gettoken-------------"

    end

    def get_media_url(media_id)
      # private method
      uri = URI("https://graph.instagram.com/#{media_id}?fields=media_url&access_token=#{ENV['USER_TOKEN']}")
      begin
        resp = Net::HTTP.get_response(uri).body
        resp = JSON.parse(resp)
      rescue => e
        e.response
      end
      media_url = resp["media_url"]
      return media_url
    end


    def show_image
      # project_id をparamsでもらうように
      project = Project.find_by(id: params[:id])
      if project then
        @project = project
      else
        flash[:caution] = 'project doesnt exist'
        redirect_to request.referer
      end
      #
      # userの全mediaのmedia-idのリストを作成
      @media_urls = []
      uri = URI("https://graph.instagram.com/me/media?fields=id&access_token=#{ENV['USER_TOKEN']}")
      resp = Net::HTTP.get_response(uri).body
      resp = JSON.parse(resp)
      media = resp["data"]
      # {data: [{id: hoge}, {id: foo},,,]}

      # userの全メディアloop
      media.each do |m|
        uri = URI("https://graph.instagram.com/#{m["id"]}?fields=id,media_url&access_token=#{ENV['USER_TOKEN']}")
        resp
        begin
          resp = Net::HTTP.get_response(uri).body
          resp = JSON.parse(resp)
        rescue => e
          puts e
        end

        # albumの場合は、各写真や動画に応じてurlを取得する必要がある
        if resp["media_type"] == "CAROUSEL_ALBUM" then
          uri = URI("https://graph.instagram.com/#{resp["id"]}/children?access_token=#{ENV['USER_TOKEN']}")
          data
          begin
            in_resp = Net::HTTP.get_response(uri).body
            in_resp = JSON.parse(resp)
            data = in_resp["data"]
          rescue => e
            puts e
          end
          data.each do |d|
            # 同じページで定義してある関数を利用
            @media_urls.push(get_media_url(d["id"]))
          end
        else
          @media_urls.push(resp["media_url"])
        end

      end
    end

    # 画像urlをそのpostのテーブルに追加
    # 画像urlのリストをquerystringとして受け取ることにする(とりあえず)
    # image-tableへは、show_imageのviewで行うことにする
    # ここでは、postとimageの関係性を作るだけ
    def insert_image_to_post
      image_ids = params[:images]
      post_id = params[:post]
      # post-image table
      image_ids.each do |i|
        Image_posts.create(image_id: i, post_id: post_id)
      end
      # postへのリダイレクト
      redirect_to 
    end



end
