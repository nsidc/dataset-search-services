require File.join(File.dirname(__FILE__), '..', 'utils', 'class_module')
require File.join(File.dirname(__FILE__), 'validator')
require File.join(File.dirname(__FILE__), 'search_adapter')

module NsidcOpenSearch
  module Search
    extend ClassModule

    include Validator::InstanceMethods
    include SearchAdapter::InstanceMethods

    module ClassMethods
      include Validator::ClassMethods
      include SearchAdapter::ClassMethods
    end

    def exec(parameters)
      validate! parameters

      unless valid?
        fail ArgumentError, 'Invalid search query. The query must contain all parameters specified'\
                            'in the OpenSearch description document.'
      end

      execute_search(parameters, valid_terms)
    end

    def exec_rest(parameters)
      result = execute_search parameters, valid_terms
      result
    end
  end
end
