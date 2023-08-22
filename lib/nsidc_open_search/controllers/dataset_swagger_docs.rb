# frozen_string_literal: true

require 'sinatra/base'
require_relative '../routes'

module NsidcOpenSearch
  module Controllers
    module DatasetSwaggerDocs
      def self.registered(app)
        app.get Routes.named(:dataset_swagger_docs), provides: [:json] do
          json_string = File.read(File.expand_path('../../docs/swagger_docs.json', __dir__))
          swagger_json = JSON.parse(json_string)

          unless %w[production development].include? ENV['RACK_ENV']
            swagger_json['basePath'].gsub!('nsidc.org', "#{ENV['RACK_ENV']}.nsidc.org")
          end
          swagger_json.to_json
        end
      end
    end
  end
end

Sinatra.register NsidcOpenSearch::Controllers::DatasetSwaggerDocs
