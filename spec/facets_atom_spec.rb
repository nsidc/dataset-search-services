# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/model/facets/facets_response_builder'
require_relative '../lib/nsidc_open_search/dataset/model/facets/facet_entry'
require_relative '../lib/nsidc_open_search/dataset/model/facets/facet_value'

describe NsidcOpenSearch::Dataset::Model::Facets::FacetsResponseBuilder do
  describe 'result to atom' do
    let(:facet_filters) { '{dataCenter: ["x","y"],authors:["a"],facet_spatial_scope:["r"]}' }
    let(:result) do
      described_class.new(
        total_results: 1,
        search_parameters: {
          startIndex: '1',
          count: '10',
          searchTerms: 'sea ice',
          facetFilters: facet_filters
        },
        entries: [
          NsidcOpenSearch::Dataset::Model::Facets::FacetEntry.new(
            name: 'Data Center',
            items: [
              NsidcOpenSearch::Dataset::Model::Facets::FacetValue.new(name: 'x', hits: '23'),
              NsidcOpenSearch::Dataset::Model::Facets::FacetValue.new(name: 'y', hits: '21'),
              NsidcOpenSearch::Dataset::Model::Facets::FacetValue.new(name: 'z', hits: '19')
            ]
          ),
          NsidcOpenSearch::Dataset::Model::Facets::FacetEntry.new(
            name: 'Author',
            items: [
              NsidcOpenSearch::Dataset::Model::Facets::FacetValue.new(name: 'a', hits: '100'),
              NsidcOpenSearch::Dataset::Model::Facets::FacetValue.new(name: 'b', hits: '81')
            ]
          ),
          NsidcOpenSearch::Dataset::Model::Facets::FacetEntry.new(
            name: 'Spatial Scope',
            items: [
              NsidcOpenSearch::Dataset::Model::Facets::FacetValue.new(name: 'r', hits: '10')
            ]
          )
        ]
      )
    end

    it 'outputs a valid atom format' do
      xml = result.to_atom(
        "localhost/dataset?searchTerms=sea ice&facetFilters=#{facet_filters}",
        'localhost'
      )

      expect(xml).to have_atom_root_element
      expect(xml).to have_atom_namespace
      expect(xml).to have_atom_opensearch_namespace
      expect(xml).to have_an_id
      expect(xml).to have_a_title
      expect(xml).to have_an_updated
      expect(xml).to have_a_total_results
      expect(xml).to have_a_query

      expect(xml).to have_three_facets
    end
  end
end
