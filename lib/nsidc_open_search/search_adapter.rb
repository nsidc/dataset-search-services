# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '..', 'utils', 'class_module')

module NsidcOpenSearch
  module SearchAdapter
    extend ClassModule

    module ClassMethods
      def search(search_impl)
        send :define_method, :search do
          search_impl
        end
      end

      def param_factory(param_factory_impl)
        send :define_method, :param_factory do
          param_factory_impl
        end
      end
    end

    module InstanceMethods
      def execute_search(parameters, valid_terms)
        search.execute param_factory.construct(parameters, valid_terms)
      end
    end
  end
end
