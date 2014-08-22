require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'utils', 'auto_initializer')

module NsidcOpenSearch
  module Dataset
    module Model
      module Facets
        class FacetValue < AutoInitializer
          attr_accessor :name, :hits

          def initialize(args)
            super args
          end
        end
      end
    end
  end
end
