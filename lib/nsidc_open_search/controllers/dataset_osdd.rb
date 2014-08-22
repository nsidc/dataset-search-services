require 'sinatra/base'
require File.join(File.dirname(__FILE__), '..', 'dataset_osdd')
require File.join(File.dirname(__FILE__), '..', 'routes')

module NsidcOpenSearch
  module Controllers
    module DatasetOsdd
      def self.registered(app)
        app.get Routes.named(:dataset_osdd), provides: [:osdd, :xml] do
          @osdd ||= NsidcOpenSearch::DatasetOsdd.new base_url
          @osdd.to_xml
        end
      end
    end
  end
end

Sinatra.register NsidcOpenSearch::Controllers::DatasetOsdd
