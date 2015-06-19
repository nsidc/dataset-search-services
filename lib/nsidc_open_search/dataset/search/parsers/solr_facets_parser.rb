require_relative '../../model/facets/facet_entry'
require_relative '../../model/facets/facet_value'

module NsidcOpenSearch
  module Dataset
    module Search
      class SolrFacetsParser
        attr_reader :total_results, :entries

        NOT_SPECIFIED = 'Not specified'

        def initialize(options)
          @config = options[:services_config]
          @total_results = options[:response].facets.count
          @entries = parse_docs options[:response].facets
        end

        private

        def parse_docs(facets)
          facets.map do |facet|
            NsidcOpenSearch::Dataset::Model::Facets::FacetEntry.new(
              id: facet.name, name: facet.name, items: populate_facet(facet)
            )
          end
        end

        def populate_facet(facet)
          facet = sort_facet facet
          facet.items.map do |f|
            NsidcOpenSearch::Dataset::Model::Facets::FacetValue.new(
              name: f.value, hits: f.hits
            )
          end
        end

        def sort_facet(facet)
          facet_config = select_facet(facet)
          if !facet_config.nil? && !facet_config['sort'].nil?
            return send(facet_config['sort'], facet, facet_config)
          end
          facet
        end

        def select_facet(facet)
          @config['facets'].find { |this| (this['name'] == facet.name) }
        end

        def defined_sort(facet, facet_config)
          result = facet.items.sort do |x, y|
            (facet_config['sort_order'].index { |el| el == x.value } || facet.items.size) <=>
            (facet_config['sort_order'].index { |el| el == y.value } || facet.items.size)
          end
          RSolr::Ext::Response::Facets::FacetField.new(facet.name, result)
        end

        def short_name_sort(facet, _facet_config)
          result = facet.items.sort do |x, y|
            x_long_name, x_short_name = x.value.split(/ \| /)
            y_long_name, y_short_name = y.value.split(/ \| /)

            if x_short_name.nil? || y_short_name.nil?
              x_long_name <=> y_long_name
            else
              x_short_name <=> y_short_name
            end
          end
          RSolr::Ext::Response::Facets::FacetField.new(facet.name, result)
        end

        # sort alphabetically with 'Not specified' last in the list
        def not_specified_last(facet, _facet_config)
          result = facet.items.sort do |x, y|
            if x.value == NOT_SPECIFIED
              1
            elsif y.value == NOT_SPECIFIED
              -1
            else
              x.value <=> y.value
            end
          end
          RSolr::Ext::Response::Facets::FacetField.new(facet.name, result)
        end
      end
    end
  end
end
