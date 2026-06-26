# frozen_string_literal: true

module NsidcOpenSearch
  module Dataset
    module Search
      class SolrSearchBase
        def initialize(url, response_parser, response_builder, query_config, solr_client)
          @solr = solr_client.connect(url:)
          if @solr.respond_to?(:connection)
            # If there is a connection object, make sure it's set to ignore self-signed certs
            # For tests, the mocks don't have a connection method, so we don't need this for testing
            @solr.connection.ssl.verify = false
            @solr.connection.ssl.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          @response_parser = response_parser
          @response_builder = response_builder
          @query_configs = query_config
        end

        def execute(search_params)
          solr_params = build_solr_params(search_params, @query_configs[search_params[:source]])

          response = @response_parser.new(
            response: query_solr(solr_params),
            services_config: @query_configs[search_params[:source]]
          )

          @response_builder.new(get_response_builder_params(response, search_params))
        end

        private

        # subclasses probably want to implement build_solr_params
        def build_solr_params(search_params, _config)
          search_params
        end

        def get_response_builder_params(response, search_params)
          {
            entries: response.entries,
            search_parameters: search_params,
            total_results: response.total_results
          }
        end

        def query_solr(solr_params)
          @solr.find(solr_params, method: :get)
        end
      end
    end
  end
end
