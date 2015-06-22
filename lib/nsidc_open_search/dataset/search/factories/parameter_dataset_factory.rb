require File.join(File.dirname(__FILE__), 'parameter_factory')
require 'uri'

module NsidcOpenSearch
  module Dataset
    module Search
      class DatasetParameterFactory < ParameterFactory
        def self.construct(query_params, _valid_terms)
          search_params = {}
          search_params[:id] =  "\"#{URI.escape(query_params[:splat].first)}\"" if query_params[:splat] && !query_params[:splat].first.nil_or_whitespace?
          # Ensure have some default values before returning the params
          {
            source: DEFAULT_SOURCE,
            count: '0',
            startIndex: DEFAULT_START_INDEX
          }.merge(search_params)
        end
      end
    end
  end
end
