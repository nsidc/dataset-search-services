# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/cross_origin'
require 'yard'
require 'yard-sinatra'
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
      forwarded_for = (env['HTTP_X_FORWARDED_FOR'] || '').split(',').map(&:strip)
      forwarded_for.delete_if { |addr| addr =~ /unknown/i }

      forwarded_for.first || request.ip
    end

    register Sinatra::CrossOrigin

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

    before do
      # The X-Requested-With response header is necessary for cross-origin
      # requests if the browser does a preflight request
      response.headers['Access-Control-Allow-Headers'] = '*, X-Requested-With, Content-Type, ' \
                                                         'Cache-Control, Accept, AUTHORIZATION'

      query_string = request.env['rack.request.query_string'].gsub('&', '&amp;')

      # NOTE: that Puma does not play nice here, it overrides rack default env methods.
      # request.env will only be used for the tests or if the app is running with other server.
      remote_ip = remote_ip(env, request)
      requested_with = env['HTTP_X_REQUESTED_WITH'] || request.env['X-Requested-With']

      if query_string.length.positive? &&
         (requested_with != 'spec_test') &&
         !request.path.include?('suggest')

        puts "New request from: #{remote_ip} requested with: #{requested_with}"

      end
    end

    helpers NsidcOpenSearch::AppHelpers
    register NsidcOpenSearch::Controllers::DatasetOsdd
    register NsidcOpenSearch::Controllers::DatasetSwaggerDocs
    register NsidcOpenSearch::Controllers::DatasetSearch
    register NsidcOpenSearch::Controllers::DatasetFacets
    register NsidcOpenSearch::Controllers::DatasetRest
    register NsidcOpenSearch::Controllers::DatasetSuggestions

    # Retrieve information about service endpoints
    # @return [Array] An array of hashes containing route information
    def self.route_summary
      # Force YARD to reload controller files.
      YARD::Registry.load(Dir.glob('./lib/**/controllers'), true)
      routes = YARD::Sinatra.routes.map do |r|
        # r.http_path returns the string "Routes.named(blah)", NOT the path that is
        # encoded in the Routes module. Can't find a way to get the value represented
        # by this string other than parsing out "blah" and actually calling the
        # Routes method "named" with "blah" as an argument.
        path_method = /([^(]+)\(:(.*)\)/.match(r.http_path)[2].to_sym
        { verb: r.http_verb,
          http_path: "(/:api_version)#{Routes.named(path_method)}",
          file: r.file,
          line: r.line,
          desc: r.docstring.tr("\n", ' ') }
      end
      routes.sort_by { |r| r[:verb] }
    end
  end
end
