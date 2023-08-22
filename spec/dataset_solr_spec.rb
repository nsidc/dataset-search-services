# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/solr_search_dataset'
require_relative '../lib/nsidc_open_search/dataset/model/search/open_search_response_builder'

describe NsidcOpenSearch::Dataset::Search::SolrSearchRest do
  let(:default_search_expectations) do
    {
      :queries => { authoritative_id: 'abcd' },
      'start' => '0',
      'rows' => '1'
    }
  end

  let(:base_search_parameters) do
    {
      id: 'abcd',
      source: 'NSIDC',
      count: '0',
      startIndex: '1'
    }
  end

  let(:solr_response) do
    YAML.load_file(File.expand_path('fixtures/solr_response.yaml', __dir__))
  end

  let(:rsolr) { instance_double(RSolr::Ext::Client, find: solr_response) }
  let(:query_config) do
    YAML.load_file(File.expand_path('../config/solr_query_config_test.yml', __dir__))
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

  before do
    allow(RSolr::Ext).to receive(:connect).and_return(rsolr)
  end

  describe 'dataset request' do
    # This is basically duplicating the normal query test, verifying that we use
    # the same constraints but using a different parser/builder.

    it 'generates default query with empty search' do
      solr_search.execute base_search_parameters
      expect(rsolr).to have_received(:find).with(
        hash_including(default_search_expectations), any_args
      )
    end

    it 'generates keyword query with keyword execute' do
      solr_search.execute base_search_parameters.merge(id: 'http://one.com')
      expect(rsolr).to have_received(:find).with(
        hash_including(queries: { authoritative_id: 'http://one.com' }), any_args
      )
    end

    it 'preserves operators with a keyword search' do
      solr_search.execute base_search_parameters.merge(id: 'abcd123')
      expect(rsolr).to have_received(:find).with(
        hash_including(queries: { authoritative_id: 'abcd123' }), any_args
      )
    end
  end
end
