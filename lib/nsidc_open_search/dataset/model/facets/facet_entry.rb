# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'utils', 'auto_initializer')

module NsidcOpenSearch
  module Dataset
    module Model
      module Facets
        class FacetEntry < AutoInitializer
          attr_accessor :id, :name, :items, :url

          def initialize(args)
            @value = []
            super
          end
        end
      end
    end
  end
end
