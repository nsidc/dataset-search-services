require_relative 'parameter_factory'
require 'uri'

module NsidcOpenSearch
  module Dataset
    module Search
      class DatasetParameterFactory < ParameterFactory
        def self.construct(query_params, _valid_terms)
          search_params = {}

          if query_params[:splat] && !query_params[:splat].first.nil_or_whitespace?
            search_params[:id] =  %("#{URI::Parser.new.escape(query_params[:splat].first)}")
          end

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
