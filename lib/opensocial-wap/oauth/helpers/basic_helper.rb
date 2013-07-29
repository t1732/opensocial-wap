# -*- coding: utf-8 -*-
require 'oauth'
require 'oauth/signature/rsa/sha1'

module OpensocialWap
  module OAuth
    module Helpers
      # Opensocial 規約の共通処理
      class BasicHelper < Base

        class << self
          # FIXME: 以下はほぼ attr_accessor :xxx で済む

          def consumer_key(arg = nil)
            if arg
              @consumer_key = arg
            end
            @consumer_key
          end

          def consumer_secret(arg = nil)
            if arg
              @consumer_secret = arg
            end
            @consumer_secret
          end

          def api_endpoint(arg = nil)
            if arg
              @api_endpoint = arg
            end
            @api_endpoint
          end

          def sp_api_endpoint(arg = nil)
            if arg
              @sp_api_endpoint = arg
            end
            @sp_api_endpoint || api_endpoint
          end

          def app_id(arg = nil)
            if arg
              @app_id = arg
            end
            @app_id
          end

          def proxy_class(arg = nil)
            if arg
              @proxy_class = arg
            end
            @proxy_class || DEFAULT_PROXY_CLASS
          end

          def configure(&block)
            instance_eval(&block)
            self
          end
        end

        DEFAULT_PROXY_CLASS = ::OpensocialWap::OAuth::RequestProxy::OAuthRackRequestProxy

        def verify(options = nil)
          request_proxy = self.class.proxy_class.new(@request)

          opts = {
            :consumer_secret => self.class.consumer_secret,
            :token_secret => request_proxy.parameters['oauth_token_secret'] }
          @access_token = ::OAuth::AccessToken.new(consumer,
            request_proxy.parameters['oauth_token'],
            request_proxy.parameters['oauth_token_secret'])
          signature = ::OAuth::Signature.build(request_proxy, opts)

          if logger = @request.logger
            logger.debug "oauth signature : #{::OAuth::Signature.sign(request_proxy, opts)}"
            logger.debug "=== OauthHandler OAuth verification: ==="
            logger.debug "  authorization header: #{@request.env['HTTP_AUTHORIZATION']}"
            logger.debug "  base string:          #{signature.signature_base_string}"
            logger.debug "  signature:            #{signature.signature}"
          end

          signature.verify
        rescue Exception => e
          false
        end

        def authorization_header(api_request, options = nil)
          opts = { :consumer => consumer }
          opts[:token] = access_token if access_token
          if @request
            opts[:xoauth_requestor_id] = @request.params['opensocial_viewer_id'] || @request.params['opensocial_owner_id'] || @request.session.try(:[], :opensocial_viewer_id)
          end
          oauth_client_helper = ::OAuth::Client::Helper.new(api_request, opts.merge(options))
          oauth_client_helper.header
        end

        #
        # FP, SPでendpointを切り替える
        #
        def api_endpoint
          if @request.respond_to?(:mobile?) && @request.mobile?
            self.class.api_endpoint
          else
            self.class.sp_api_endpoint
          end
        end

        def consumer
          @consumer ||= ::OAuth::Consumer.new(self.class.consumer_key, self.class.consumer_secret)
        end

        def access_token
          @access_token
        end
      end
    end
  end
end
