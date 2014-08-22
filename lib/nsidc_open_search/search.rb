require File.join(File.dirname(__FILE__), '..', 'utils', 'class_module')
require File.join(File.dirname(__FILE__), 'validator')
require File.join(File.dirname(__FILE__), 'search_adapter')
require File.join(File.dirname(__FILE__), 'enricher')

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
      validate! parameters
      fail 'Invalid search query. The query must contain all parameters specified in the OpenSearch description document' unless valid?

      result = execute_search parameters, valid_terms
      enrich_result result

      result
    end

    def exec_rest(parameters)
      result = execute_search parameters, valid_terms
      result
    end
  end
end
