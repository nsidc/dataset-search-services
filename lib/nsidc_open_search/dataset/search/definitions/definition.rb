require 'ostruct'

module NsidcOpenSearch
  module Dataset
    module Search
      module Definition
        def self.searchTerms
          create_parameter 'searchTerms', 'Sea Ice'
        end

        def self.id
          create_parameter 'nsidc:authoritativeId', 'NSIDC-046'
        end

        def self.source
          create_parameter 'nsidc:source', 'NSIDC'
        end

        def self.count
          create_parameter 'count', '25'
        end

        def self.startIndex
          create_parameter 'startIndex', '1'
        end

        def self.spatial
          create_parameter 'geo:box', '100,10,110,20'
        end

        def self.loc
          create_parameter 'geo:polygon', '10,100,20,100,20,110,10,110,10,100'
        end

        def self.startDate
          create_parameter 'time:start', '2009-01-01'
        end

        def self.endDate
          create_parameter 'time:end', '2009-01-31'
        end

        def self.queryType
          create_parameter 'nsidc:query', 'facet'
        end

        def self.facetFilters
          create_parameter 'nsidc:facetFilters', '{facet_1: ["x","y"],facet_2:["a"]}'
        end

        def self.sortKeys
          create_parameter 'sortKeys', 'path,,asc'
        end

        def self.valids
          [{
            required: [],
            optional: [
              :searchTerms,
              :spatial,
              :startDate,
              :endDate,
              :startIndex,
              :count,
              :source,
              :facetFilters,
              :sortKeys
            ]
          }]
        end

        private

        def self.create_parameter(replacement, example)
          OpenStruct.new replacement: replacement, example: example
        end
      end
    end
  end
end
