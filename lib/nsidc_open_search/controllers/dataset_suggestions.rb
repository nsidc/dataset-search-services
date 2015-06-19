require 'sinatra/base'
require_relative '../routes'
require_relative '../dataset_suggestions'

module NsidcOpenSearch
  module Controllers
    module DatasetSuggestions
      def self.registered(app)
        app.get Routes.named(:dataset_suggestions), provides: [:suggestions, :json] do
          content_type 'application/x-suggestions+json'
          NsidcOpenSearch::DatasetSuggestions.new(
            settings.solr_auto_suggest_url,
            settings.query_config
          ).exec(params).to_json
        end
      end
    end
  end
end

Sinatra.register NsidcOpenSearch::Controllers::DatasetSuggestions
