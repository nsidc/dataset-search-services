require 'yaml'
require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/solr_search_dataset'
require_relative '../lib/nsidc_open_search/dataset/model/search/open_search_response_builder'

describe NsidcOpenSearch::Dataset::Search::SolrSearchDataset do
  let(:default_search_expectations) {
    YAML.load_file(File.expand_path('../fixtures/default_search_expectations.yaml', __FILE__))
  }

  let(:base_search_parameters) {
    {
      source: 'NSIDC',
      count: '25',
      startIndex: '1',
      sortKeys: ''
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
      NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder,
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

    it 'generates default query with empty search' do
      get_should_receive_expectations default_search_expectations
      solr_search.execute base_search_parameters
    end

    it 'generats default query with empty keyword search' do
      get_should_receive_expectations default_search_expectations
      solr_search.execute base_search_parameters.merge(searchTerms: '')
    end

    it 'generates keyword query with keyword execute' do
      get_should_receive_expectations 'q' => 'sea AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: 'sea ice')
    end

    it 'generates query with offset start index' do
      get_should_receive_expectations 'start' => 25
      solr_search.execute base_search_parameters.merge(startIndex: '26')
    end

    it 'generates a sort field with the indexed field to sort on and which direction to sort' do
      get_should_receive_expectations 'sort' => 'last_revision_date desc'
      solr_search.execute base_search_parameters.merge(sortKeys: 'updated,,0')
    end

    it 'preserves operators with a keyword search' do
      get_should_receive_expectations 'q' => 'sea AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: 'sea OR ice')
    end

    it 'strips quotes from phrase strings with a keyword search' do
      get_should_receive_expectations 'q' => 'sea AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: '"sea ice"')
    end

    it 'strips single character words/numbers from phrase strings with a keyword search' do
      get_should_receive_expectations 'q' => 'sea AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: '"a sea 4 ice"')
    end

    it 'preserves single quotes for contractions with a keyword search' do
      get_should_receive_expectations 'q' => 'the AND sea\'s AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: "the sea's ice")
    end

    it 'preserves quoted strings and operators with a keyword search' do
      get_should_receive_expectations 'q' => 'arctic AND sea AND ice'
      solr_search.execute base_search_parameters.merge(searchTerms: 'arctic OR "sea ice"')
    end

    it 'escapes parenthesis from phrase strings with a keyword search' do
      get_should_receive_expectations 'q' => 'sea AND ice AND \(2013-2014\)'
      solr_search.execute base_search_parameters.merge(searchTerms: '"sea ice (2013-2014)"')
    end

    it 'generates filter query with source' do
      get_should_receive_expectations 'fq' => %w(source:NSIDC)
      solr_search.execute base_search_parameters
    end

    it 'generates filter query with facetFilters parameter' do
      data_center = 'Norwegian%20Meteorological%20Institute'

      fq = [
        'source:NSIDC',
        %({!tag=facet_data_center}facet_data_center:("#{data_center}"))
      ]

      params = {
        facetFilters: %({"facet_data_center":["#{data_center}"]})
      }

      get_should_receive_expectations 'fq' => fq
      solr_search.execute base_search_parameters.merge(params)
    end

    it 'generates filter query with facetFilters with multiple filters' do
      get_should_receive_expectations(
        'fq' => [
          'source:NSIDC',
          '{!tag=facet_data_center}facet_data_center:'\
            '("Norwegian%20Meteorological%20Institute" "NSIDC")',
          '{!tag=facet_temporal_duration}facet_temporal_duration:("1-5")'
        ]
      )
      params = {
        facetFilters: {
          facet_data_center: %w(Norwegian%20Meteorological%20Institute NSIDC),
          facet_temporal_duration: %w(1-5)
        }.to_json
      }
      solr_search.execute(base_search_parameters.merge(params))
    end

    it 'ignores the facetFilter parameter if it is not proper JSON, source is taken by default' do
      get_should_receive_expectations('fq' => %w(source:NSIDC))

      params = {
        facetFilters: %({
          "facet_data_center":["Norwegian%20Meteorological%20Institute","NSIDC"],
          $%#$%#% -> "dummy_value"]
        })
      }

      solr_search.execute(base_search_parameters.merge(params))
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
      get_should_receive_expectations('q' => 'temporal:[20.1001009,0 TO 90,20.1101011]')

      solr_search.execute(
        base_search_parameters.merge(
          startDate: '2010-01-01',
          endDate: '2011-01-01'
        )
      )
    end
  end

  describe 'search result' do
    it 'should set total results count to number found' do
      result = solr_search.execute base_search_parameters
      expect(result.total_results).to be solr_response['response']['numFound']
    end

    it 'should set set the search dsl to itself' do
      result = solr_search.execute base_search_parameters
      expect(result.search_parameters).to eql base_search_parameters
    end

    it 'should set entities to returned documents' do
      result = solr_search.execute base_search_parameters
      expect(result.entries.length).to be solr_response['response']['docs'].length
    end
  end
end

describe NsidcOpenSearch::Dataset::Search::SolrSearchFacets do
  let(:base_search_parameters) {
    {
      source: 'NSIDC',
      count: '25',
      startIndex: '1',
      sortKeys: ''
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
      NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder,
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

    it 'generates default facet values in facet query' do
      get_should_receive_expectations 'facet' => 'true'
      solr_search.execute base_search_parameters
    end

    it 'generates facet field string' do
      facet_field = query_config[base_search_parameters[:source]]['facets'].map do |facet|
        "{!ex=#{facet['name']}}#{facet['name']}"
      end

      get_should_receive_expectations('facet.field' => facet_field)
      solr_search.execute(base_search_parameters)
    end

    it 'generates facet field options override strings' do
      get_should_receive_expectations(
        'f.facet_spatial_coverage.facet.sort' => 'count',
        'f.facet_spatial_coverage.facet.mincount' => 0
      )
      solr_search.execute(base_search_parameters)
    end
  end
end
