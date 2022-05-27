require 'uri'

class InstagramAuthController < ApplicationController
    def index
    end

    # instagram認証ボタン
    def auth

    end

    # リダイレクト先
    # もらったcodeをpush
    def auth_pass
      code = params[:code]

    end

    # access_tokenもらう
    def auth_get_token
      token = params[:access_token]
      user_id = params[:user_id]
    end

    def 

    end
