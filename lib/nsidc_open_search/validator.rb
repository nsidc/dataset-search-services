require 'set'
require File.join(File.dirname(__FILE__), '..', 'utils', 'class_module')

module NsidcOpenSearch
  module Validator
    extend ClassModule

    module ClassMethods
      def search_definition(definition)
        send :define_method, :search_definition do
          definition
        end
      end
    end

    module InstanceMethods
      def valid?
        @is_valid || false
      end

      def valid_terms
        @valid_terms || []
      end

      def validate!(parameters)
        valids = search_definition.valids

        valids.each do |terms|
          # must include all required terms; if not, continue to the next set of
          # valids
          next unless terms[:required].all? do |t|
            parameters.include?(t) || parameters.include?(t.to_s)
          end

          # cannot include anything outside of required and optional
          valid_set = Set.new([terms[:required], terms[:optional]].flatten)

          param_keys = parameters.keys.map(&:to_sym)
          param_set = Set.new(param_keys)

          if param_set.subset?(valid_set)
            @is_valid = true
            @valid_terms = param_keys
            break
          end
        end
      end
    end
  end
end
