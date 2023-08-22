# frozen_string_literal: true

require 'sinatra/base'
require 'uri'
require_relative '../routes'
require_relative '../dataset_rest'

module NsidcOpenSearch
  module Controllers
    module DatasetRest
      def self.registered(app)
        app.get Routes.named(:dataset_rest), provides: %i[atom xml] do
          dataset = DatasetRest.dataset(settings, params)

          if params[:splat].first.nil_or_whitespace? || dataset.total_results.zero?
            status 404
          else
            parser = URI::Parser.new
            dataset.to_atom(parser.escape(request.url), parser.escape(base_url))
          end
        end
      end

      def self.dataset(settings, params)
        NsidcOpenSearch::DatasetRest.new(
          settings.solr_url,
          settings.query_config
        ).exec_rest(params)
      end
    end
  end
end

Sinatra.register NsidcOpenSearch::Controllers::DatasetRest
