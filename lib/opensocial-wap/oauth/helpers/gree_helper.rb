# -*- coding: utf-8 -*-
module OpensocialWap::OAuth::Helpers
  #
  # GREE 用 oauthヘルパー
  #   SP版のiflame内ではプラットフォームを介さずverifyを通らないため予めsessionに格納しておいた情報でtokenを生成する
  #
  class GreeHelper < BasicHelper
    def access_token
      if defined?(Rails::Railtie) && Rack::Request === @request
        config = Rails.application.config
        if config.respond_to?(:opensocial_wap) && config.opensocial_wap.url.call(@request).default[:format].in?([:local])
          return OAuth::AccessToken.new(consumer, @request.session[:oauth_token], @request.session[:oauth_token_secret])
        end
      end

      @access_token
    end
  end
end
