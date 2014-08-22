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
          [{ required: [:q, :source], optional: [] }]
        end

        private

        def self.create_parameter(replacement, example)
          OpenStruct.new replacement: replacement, example: example
        end
      end
    end
  end
end
