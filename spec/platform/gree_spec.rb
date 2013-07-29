# -*- coding: utf-8 -*-
require 'spec_helper'

describe OpensocialWap::Platform do
  describe "gree" do
    context "gree用の初期化が正しく行えること" do
      before do
        @config = Rails::Application::Configuration.new
        OpensocialWap::Platform.gree(@config) do
          consumer_key '(consumer_key)'
          consumer_secret '(consumer_secret)'
          sandbox true
          session false
        end
      end

      it do
        @config.opensocial_wap.oauth.helper_class.should                 == OpensocialWap::OAuth::Helpers::GreeHelper
        @config.opensocial_wap.oauth.helper_class.proxy_class.should     == OpensocialWap::OAuth::RequestProxy::OAuthRackRequestProxyForGree
        @config.opensocial_wap.oauth.helper_class.consumer_key.should    == '(consumer_key)'
        @config.opensocial_wap.oauth.helper_class.consumer_secret.should == '(consumer_secret)'
        @config.opensocial_wap.oauth.helper_class.api_endpoint.should    == 'http://os-sb.gree.jp/api/rest/'
        @config.opensocial_wap.oauth.helper_class.sp_api_endpoint.should == 'http://os-sb.gree.jp/api/rest/'
        @config.opensocial_wap.session_id.should_not == :parameter
      end

      it "opensocial_wap.url は Proc で controller を渡すと request.mobile? の結果で切り替わる" do
        ctx = Object.new
        ctx.stub_chain(:request, :mobile?).and_return(true)
        retval = @config.opensocial_wap.url.call(ctx)
        retval.default.should == {:format => :query, :params => {:guid => "ON"}}

        ctx = Object.new
        ctx.stub_chain(:request, :mobile?).and_return(false)
        retval = @config.opensocial_wap.url.call(ctx)
        retval.default.should == {:format => :local}
      end
    end
  end
end
