require File.join(File.dirname(__FILE__), 'parameter_factory')

module NsidcOpenSearch
  module Dataset
    module Search
      class ResultsParameterFactory < ParameterFactory
        def self.construct(query_params, valid_terms)
          # Ensure have some default values before returning the params
          {
            source: DEFAULT_SOURCE,
            count: DEFAULT_ITEMS_PER_PAGE,
            startIndex: DEFAULT_START_INDEX
          }.merge(super(query_params, valid_terms))
        end
      end
    end
  end
end
