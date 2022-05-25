require 'uri'

class InstagramAuthController < ApplicationController
    def index
    end

    # instagram認証ボタンを押すと発動
    def auth

    end

    # instagramに指定するリダイレクト先
    # 4段階 codeをparamsから取って、再びpush
    def auth_pass
      code = params[:code]

    end

    # トークン受け取り
    def auth_get_token
      token = params[:access_token]
      user_id = params[:user_id]
    end

    def 

    end
