require 'sinatra/base'
require 'uri'
require File.join(File.dirname(__FILE__), '..', 'routes')
require File.join(File.dirname(__FILE__), '..', 'dataset_rest')

module NsidcOpenSearch
  module Controllers
    module DatasetRest
      def self.registered(app)
        app.get Routes.named(:dataset_rest), provides: [:atom, :xml] do
          (status 404) if URI.escape(params[:splat].first).nil_or_whitespace?
          dataset = NsidcOpenSearch::DatasetRest.new(settings.solr_url, settings.query_config).exec_rest(params)
          dataset.entries.count  == 1 ? dataset.to_atom(URI.escape(request.url), URI.escape(base_url)) : (status 404)
        end
      end
    end
  end
end

Sinatra.register NsidcOpenSearch::Controllers::DatasetRest
