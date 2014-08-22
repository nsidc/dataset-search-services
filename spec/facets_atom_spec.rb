require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'model', 'facets', 'facets_response_builder')
require File.join(File.dirname(__FILE__), '..', 'lib',  'nsidc_open_search', 'dataset', 'model', 'facets', 'facet_entry')
require File.join(File.dirname(__FILE__), '..', 'lib',  'nsidc_open_search', 'dataset', 'model', 'facets', 'facet_value')

describe 'facets response' do
  describe 'result to atom' do
    before :each do
      @facet_filters = '{dataCenter: ["x","y"],authors:["a"],facet_spatial_scope:["r"]}'
      @result = NsidcOpenSearch::Dataset::Model::Facets::FacetsResponseBuilder.new(
        total_results: 1,
        search_parameters: {
          startIndex: '1',
          count: '10',
          searchTerms: 'sea ice',
          facetFilters: @facet_filters
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

    it 'should output a valid atom format' do
      xml = @result.to_atom 'localhost/dataset?searchTerms=sea ice&facetFilters=' + @facet_filters, 'localhost'

      xml.should have_atom_root_element
      xml.should have_atom_namespace
      xml.should have_atom_opensearch_namespace
      xml.should have_an_id
      xml.should have_a_title
      xml.should have_an_updated
      xml.should have_a_total_results
      xml.should have_a_query

      xml.should have_three_facets
    end
  end
end
