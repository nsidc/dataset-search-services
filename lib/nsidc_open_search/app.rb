require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/cross_origin'
require 'sinatra/advanced_routes'
require 'libre_metrics_client'
require File.join(File.dirname(__FILE__), '..', '..', 'config', 'app_config')
require File.join(File.dirname(__FILE__), 'helpers', 'app_helpers')
require File.join(File.dirname(__FILE__), 'controllers', 'dataset_osdd')
require File.join(File.dirname(__FILE__), 'controllers', 'dataset_search')
require File.join(File.dirname(__FILE__), 'controllers', 'dataset_swagger_docs')
require File.join(File.dirname(__FILE__), 'controllers', 'dataset_facets')
require File.join(File.dirname(__FILE__), 'controllers', 'dataset_rest')
require File.join(File.dirname(__FILE__), 'controllers', 'dataset_suggestions')

module NsidcOpenSearch
  class App < Sinatra::Base
    # The X-Forwarded-For header is of the format:
    # 'client, proxy1, proxy2, ... , proxyN', where client can
    # be 'unknown' or a real ip address.  The list of proxies
    # may be empty as well.
    def remote_ip(env, request)
      forwarded_for = env['HTTP_X_FORWARDED_FOR'].split(',').map(&:strip)
      forwarded_for.delete_if { |addr| addr =~ /unknown/i }

      forwarded_for.first || request.ip
    end

    register Sinatra::CrossOrigin
    register Sinatra::AdvancedRoutes

    configure do
      AppConfig[environment].each { |k, v| set k, v }
      mime_type :osdd, 'application/opensearchdescription+xml'
      mime_type :atom, 'application/atom+xml'
      mime_type :facets, 'application/nsidcfacets+xml'
      mime_type :suggestions, 'application/x-suggestions+json'
      enable :logging
      enable :cross_origin
    end

    options '/*' do
      200
    end

    if defined? settings.metrics_url
      libre_metrics = LibreMetricsClient::LibreMetrics.new(settings.metrics_url)
    end

    before do
      query_string = request.env['rack.request.query_string'].gsub('&', '&amp;')
      search_terms = request.env['rack.request.query_hash']['searchTerms']

      # note that Puma does not play nice here, it overrides rack default env methods.
      # request.env will only be used for the tests or if the app is running with other server.
      remote_ip = remote_ip(env, request)
      requested_with = env['HTTP_X_REQUESTED_WITH'] || request.env['X-Requested-With']

      if query_string.length > 0 && requested_with != 'spec_test' && !request.path.include?('suggest')

        puts "New request from: #{remote_ip} requested with: #{requested_with}"

        if libre_metrics
          begin
            libre_metrics.send(
              'ipAddress' => remote_ip,
              'userAgent' => request.user_agent,
              'metrics' => [
                { name: 'ip', value: remote_ip },
                { name: 'query_url', value: request.url.split('?')[0] },
                { name: 'search_terms', value: search_terms },
                { name: 'query_string', value: query_string },
                { name: 'requested_with', value: requested_with }
            ]
            )
          rescue => e
            puts 'Could not send metrics information to libre_metrics'
            puts e.message
            puts e.backtrace.inspect
          end
        end

      end
    end

    helpers NsidcOpenSearch::AppHelpers
    register NsidcOpenSearch::Controllers::DatasetOsdd
    register NsidcOpenSearch::Controllers::DatasetSwaggerDocs
    register NsidcOpenSearch::Controllers::DatasetSearch
    register NsidcOpenSearch::Controllers::DatasetFacets
    register NsidcOpenSearch::Controllers::DatasetRest
    register NsidcOpenSearch::Controllers::DatasetSuggestions
  end
end
