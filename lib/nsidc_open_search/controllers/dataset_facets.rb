# frozen_string_literal: true

require 'sinatra/base'
require_relative '../routes'
require_relative '../dataset_facets'

module NsidcOpenSearch
  module Controllers
    module DatasetFacets
      def self.registered(app)
        app.get Routes.named(:dataset_facets), provides: %i[facets xml] do
          NsidcOpenSearch::DatasetFacets.new(
            settings.solr_url,
            settings.query_config
          ).exec(params).to_atom(request.url, base_url)
        end
      end
    end
  end
end

Sinatra.register NsidcOpenSearch::Controllers::DatasetFacets
