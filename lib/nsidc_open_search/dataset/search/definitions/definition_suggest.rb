# frozen_string_literal: true

require 'ostruct'

module NsidcOpenSearch
  module Dataset
    module Search
      module DefinitionSuggest
        def self.q
          create_parameter 'searchTerms', 'sea'
        end

        def self.source
          create_parameter 'nsidc:source', 'NSIDC'
        end

        def self.valids
          [{ required: %i[q source], optional: [] }]
        end

        def self.create_parameter(replacement, example)
          Struct.new(:replacement, :example).new(replacement, example)
        end
      end
    end
  end
end
