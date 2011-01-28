# -*- coding: utf-8 -*-

require 'opensocial-wap/rack/opensocial_oauth'
require 'opensocial-wap/routing/url_for'
require 'opensocial-wap/routing/url_for'
require 'opensocial-wap/helpers/base'
require 'opensocial-wap/helpers/url_helper'
require 'opensocial-wap/helpers/form_tag_helper'
require 'opensocial-wap/action_controller/controller_hook'
require 'opensocial-wap/action_controller/metal/redirecting'

module OpensocialWap
  class Railtie < Rails::Railtie

     config.opensocial_wap = ActiveSupport::OrderedOptions.new

    initializer "opensocial-wap.initialize" do |app|
      # do something..
    end

    initializer 'opensocial-wap.load_middleware', :after=> :load_config_initializers do
      platform = config.opensocial_wap.platform

      log_level = config.opensocial_wap.log_level || :error
      if platform
        puts "opensocial-wap is enabled with #{platform.class}"
        config.app_middleware.insert_before ActionDispatch::Cookies,  OpensocialWap::Rack::OpensocialOauth, :platform=>platform, :log_level=>log_level.to_s.upcase
      else
        puts "opensocial-wap is NOT enabled" 
      end
    end

  end
end
