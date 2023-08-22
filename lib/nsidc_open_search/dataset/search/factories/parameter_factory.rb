# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'parameter_factory')

module NsidcOpenSearch
  module Dataset
    module Search
      class ParameterFactory
        DEFAULT_SOURCE = 'NSIDC'
        DEFAULT_ITEMS_PER_PAGE = '25'
        DEFAULT_START_INDEX = '1'

        def self.construct(query_params, valid_terms)
          search_params = {}
          valid_terms.each do |t|
            search_params[t] = query_params[t] unless query_params[t].nil_or_whitespace?
          end
          search_params
        end
      end
    end
  end
end
