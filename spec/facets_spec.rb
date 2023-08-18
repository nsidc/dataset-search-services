# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/solr_search_facets'
require_relative '../lib/nsidc_open_search/dataset/model/facets/facets_response_builder'

describe NsidcOpenSearch::Dataset::Search::SolrSearchFacets do
  let(:default_search_expectations) do
    YAML.load_file(File.expand_path('fixtures/default_facet_search_expectations.yaml', __dir__))
  end

  let(:base_search_parameters) do
    {
      source: 'NSIDC',
      count: '0',
      startIndex: '1',
      queryType: 'facets'
    }
  end

  let(:solr_response) do
    instance_double(
      RSolr::Ext::Response::Facets,
      facets: [
        instance_double(
          NsidcOpenSearch::Dataset::Model::Facets::FacetEntry,
          name: 'Facet1',
          items: [
            instance_double(
              RSolr::Ext::Response::Facets::FacetItem,
              value: 'dummy',
              hits: '12'
            )
          ]
        )
      ]
    )
  end

  let(:rsolr) { instance_double(RSolr::Ext::Client, find: solr_response) }
  let(:query_config) do
    YAML.load_file(File.expand_path('../config/solr_query_config_test.yml', __dir__))
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

  before do
    allow(RSolr::Ext).to receive(:connect).and_return(rsolr)
  end

  describe 'search request' do
    # This is basically duplicating the normal query test, verifying that we use
    # the same constraints but using a different parser/builder.

    it 'generates default query with empty search' do
      solr_search.execute base_search_parameters
      expect(rsolr).to have_received(:find).with(
        hash_including(default_search_expectations),
        any_args
      )
    end

    it 'generates default query with empty keyword search' do
      solr_search.execute base_search_parameters.merge(searchTerms: '')
      expect(rsolr).to have_received(:find).with(
        hash_including(default_search_expectations),
        any_args
      )
    end

    it 'generates keyword query with keyword execute' do
      solr_search.execute base_search_parameters.merge(searchTerms: 'sea ice')
      expect(rsolr).to have_received(:find).with(
        hash_including('q' => 'sea AND ice'),
        any_args
      )
    end

    it 'preserves operators with a keyword search' do
      solr_search.execute base_search_parameters.merge(searchTerms: 'sea OR ice')
      expect(rsolr).to have_received(:find).with(
        hash_including('q' => 'sea AND ice'),
        any_args
      )
    end

    it 'strips quotes from phrase strings with a keyword search' do
      solr_search.execute base_search_parameters.merge(searchTerms: '"sea ice"')
      expect(rsolr).to have_received(:find).with(
        hash_including('q' => 'sea AND ice'),
        any_args
      )
    end

    it 'preserves quoteds strings and operators with a keyword search' do
      solr_search.execute base_search_parameters.merge(searchTerms: 'arctic OR "sea ice"')
      expect(rsolr).to have_received(:find).with(
        hash_including('q' => 'arctic AND sea AND ice'),
        any_args
      )
    end

    it 'generates filter query with source' do
      solr_search.execute base_search_parameters
      expect(rsolr).to have_received(:find).with(
        hash_including('fq' => %w[source:NSIDC]),
        any_args
      )
    end

    it 'generates a geo range query with a spatial search' do
      solr_search.execute base_search_parameters.merge(spatial: '-180,45,180,90')
      expect(rsolr).to have_received(:find).with(
        hash_including('q' => 'spatial:[45,-180 TO 90,180]'),
        any_args
      )
    end

    it 'generates a date range query with start date search' do
      solr_search.execute base_search_parameters.merge(startDate: '2009-01-01')
      expect(rsolr).to have_received(:find).with(
        hash_including('q' => 'temporal:[20.0901009,0 TO 90,180]'),
        any_args
      )
    end

    it 'generates a date range query with start and end date search' do
      range = {
        startDate: '2010-01-01',
        endDate: '2011-01-01'
      }

      solr_search.execute base_search_parameters.merge(range)
      expect(rsolr).to have_received(:find).with(
        hash_including('q' => 'temporal:[20.1001009,0 TO 90,20.1101011]'),
        any_args
      )
    end
  end
end
