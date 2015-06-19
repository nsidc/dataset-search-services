require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/solr_search_facets'
require_relative '../lib/nsidc_open_search/dataset/model/facets/facets_response_builder'

describe NsidcOpenSearch::Dataset::Search::SolrSearchFacets do
  let(:default_search_expectations) {
    YAML.load_file(File.expand_path('../fixtures/default_facet_search_expectations.yaml', __FILE__))
  }

  let(:base_search_parameters) {
    {
      source: 'NSIDC',
      count: '0',
      startIndex: '1',
      queryType: 'facets'
    }
  }

  let(:solr_response) {
    double(
      'facets',
      facets: [
        double('facet', name: 'Facet1', items: [double('item', value: 'dummy', hits: '12')])
      ]
    )
  }

  let(:rsolr) { double('rsolr', find: solr_response) }
  let(:query_config) do
    YAML.load_file(File.expand_path('../../config/solr_query_config_test.yml', __FILE__))
  end
  let(:solr_search) do
    described_class.new(
      'localhost:8983',
      NsidcOpenSearch::Dataset::Search::SolrFacetsParser,
      NsidcOpenSearch::Dataset::Model::Facets::FacetsResponseBuilder,
      query_config,
      RSolr::Ext
    )
  end

  before :each do
    allow(RSolr::Ext).to receive(:connect).and_return(rsolr)
  end

  describe 'search request' do
    def get_should_receive_expectations(expected)
      expect(rsolr).to receive(:find) do |*args|
        expected.each do |k, v|
          expect(args[0][k]).to eql v
        end

        solr_response
      end
    end

    # This is basically duplicating the normal query test, verifying that we use
    # the same constraints but using a different parser/builder.

    it 'generates default query with empty search' do
      get_should_receive_expectations default_search_expectations
      solr_search.execute base_search_parameters
    end

    it 'generates default query with empty keyword search' do
      get_should_receive_expectations default_search_expectations
      solr_search.execute base_search_parameters.merge(searchTerms: '')
    end

    it 'generates keyword query with keyword execute' do
      get_should_receive_expectations 'q' => 'sea AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: 'sea ice')
    end

    it 'preserves operators with a keyword search' do
      get_should_receive_expectations 'q' => 'sea AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: 'sea OR ice')
    end

    it 'strips quotes from phrase strings with a keyword search' do
      get_should_receive_expectations 'q' => 'sea AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: '"sea ice"')
    end

    it 'preserves quoteds strings and operators with a keyword search' do
      get_should_receive_expectations 'q' => 'arctic AND sea AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: 'arctic OR "sea ice"')
    end

    it 'generates filter query with source' do
      get_should_receive_expectations 'fq' => %w(source:NSIDC)
      solr_search.execute base_search_parameters
    end

    it 'generates a geo range query with a spatial search' do
      get_should_receive_expectations 'q' => 'spatial:[45,-180 TO 90,180]'
      solr_search.execute base_search_parameters.merge(spatial: '-180,45,180,90')
    end

    it 'generates a date range query with start date search' do
      get_should_receive_expectations 'q' => 'temporal:[20.0901009,0 TO 90,180]'
      solr_search.execute base_search_parameters.merge(startDate: '2009-01-01')
    end

    it 'generates a date range query with start and end date search' do
      get_should_receive_expectations 'q' => 'temporal:[20.1001009,0 TO 90,20.1101011]'

      range = {
        startDate: '2010-01-01',
        endDate: '2011-01-01'
      }

      solr_search.execute base_search_parameters.merge(range)
    end
  end
end
