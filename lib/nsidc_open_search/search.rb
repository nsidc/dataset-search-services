# frozen_string_literal: true

require_relative '../utils/class_module'
require_relative 'enricher'
require_relative 'search_adapter'
require_relative 'validator'

module NsidcOpenSearch
  module Search
    extend ClassModule

    include Validator::InstanceMethods
    include SearchAdapter::InstanceMethods
    include Enricher::InstanceMethods

    module ClassMethods
      include Validator::ClassMethods
      include SearchAdapter::ClassMethods
      include Enricher::ClassMethods
    end

    def exec(parameters)
      validate!(parameters)

      unless valid?
        raise ArgumentError, 'Invalid search query. The query must contain all parameters ' \
                             'specified in the OpenSearch description document.'
      end

      result = exec_rest(parameters)

      enrich_result(result) unless parameters['source'] == 'ADE'

      result
    end

    def exec_rest(parameters)
      execute_search(parameters, valid_terms)
    end
  end
end
