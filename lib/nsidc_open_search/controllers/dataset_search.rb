require 'sinatra/base'
require_relative '../routes'
require_relative '../dataset_search'

module NsidcOpenSearch
  module Controllers
    module DatasetSearch
      def self.registered(app)
        app.get Routes.named(:dataset_search), provides: [:atom, :xml] do
          NsidcOpenSearch::DatasetSearch.new(
            settings.solr_url,
            settings.enricher_thread_count,
            settings.query_config
          ).exec(params).to_atom(request.url, base_url)
        end
      end
    end
  end
end

Sinatra.register NsidcOpenSearch::Controllers::DatasetSearch
