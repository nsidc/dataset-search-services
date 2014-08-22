require 'sinatra/base'
require File.join(File.dirname(__FILE__), '..', 'routes')

module NsidcOpenSearch
  module Controllers
    module DatasetSwaggerDocs
      def self.registered(app)
        app.get Routes.named(:dataset_swagger_docs), provides: [:json] do
          swagger_json = JSON.parse(File.read(File.join(File.dirname(__FILE__), '..', '..', 'docs', 'swagger_docs.json')))
          unless %w(production development).include? ENV['RACK_ENV']
            swagger_json['basePath'].gsub!('nsidc.org', "#{ENV['RACK_ENV']}.nsidc.org")
          end
          swagger_json.to_json
        end
      end
    end
  end
end

Sinatra.register NsidcOpenSearch::Controllers::DatasetSwaggerDocs
