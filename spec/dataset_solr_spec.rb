require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/solr_search_dataset'
require_relative '../lib/nsidc_open_search/dataset/model/search/open_search_response_builder'

describe NsidcOpenSearch::Dataset::Search::SolrSearchRest do
  let(:default_search_expectations) {
    {
      :queries => { authoritative_id: 'abcd' },
      'start' => '0',
      'rows' => '1'
    }
  }

  let(:base_search_parameters) {
    {
      id: 'abcd',
      source: 'NSIDC',
      count: '0',
      startIndex: '1'
    }
  }

  let(:solr_response) {
    YAML.load_file(File.expand_path('../fixtures/solr_response.yaml', __FILE__))
  }

  let(:rsolr) { double('rsolr', find: solr_response) }
  let(:query_config) do
    YAML.load_file(File.expand_path('../../config/solr_query_config_test.yml', __FILE__))
  end
  let(:solr_search) do
    described_class.new(
      'localhost:8983',
      NsidcOpenSearch::Dataset::Search::SolrResultsParser,
      NsidcOpenSearch::Dataset::Model::Facets::FacetsResponseBuilder,
      query_config,
      RSolr::Ext
    )
  end

  before :each do
    allow(RSolr::Ext).to receive(:connect).and_return(rsolr)
  end

  describe 'dataset request' do
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

    it 'generates keyword query with keyword execute' do
      get_should_receive_expectations queries: { authoritative_id: 'http://one.com' }
      solr_search.execute base_search_parameters.merge(id: 'http://one.com')
    end

    it 'preserves operators with a keyword search' do
      get_should_receive_expectations queries: { authoritative_id: 'abcd123' }
      solr_search.execute base_search_parameters.merge(id: 'abcd123')
    end
  end
end
