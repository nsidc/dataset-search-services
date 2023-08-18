# frozen_string_literal: true

require 'yaml'
require 'rsolr'
require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/solr_search_dataset'
require_relative '../lib/nsidc_open_search/dataset/model/search/open_search_response_builder'

describe NsidcOpenSearch::Dataset::Search do
  describe NsidcOpenSearch::Dataset::Search::SolrSearchDataset do
    let(:default_search_expectations) do
      YAML.load_file(File.expand_path('fixtures/default_search_expectations.yaml', __dir__))
    end

    let(:base_search_parameters) do
      {
        source: 'NSIDC',
        count: '25',
        startIndex: '1',
        sortKeys: ''
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
        NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder,
        query_config,
        RSolr::Ext
      )
    end

    before do
      allow(RSolr::Ext).to receive(:connect).and_return(rsolr)
    end

    # TODO: Consider refactoring these tests so that the expects aren't in an external function
    describe 'search request' do
      it 'generates default query with empty search' do
        solr_search.execute base_search_parameters
        expect(rsolr).to have_received(:find).with(
          hash_including(default_search_expectations),
          any_args
        )
      end

      it 'generats default query with empty keyword search' do
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

      it 'generates query with offset start index' do
        solr_search.execute base_search_parameters.merge(startIndex: '26')
        expect(rsolr).to have_received(:find).with(
          hash_including('start' => 25),
          any_args
        )
      end

      it 'generates a sort field with the indexed field to sort on and which direction to sort' do
        solr_search.execute base_search_parameters.merge(sortKeys: 'updated,,0')
        expect(rsolr).to have_received(:find).with(
          hash_including('sort' => 'last_revision_date desc'),
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

      it 'strips single character words/numbers from phrase strings with a keyword search' do
        solr_search.execute base_search_parameters.merge(searchTerms: '"a sea 4 ice"')
        expect(rsolr).to have_received(:find).with(
          hash_including('q' => 'sea AND ice'),
          any_args
        )
      end

      it 'preserves single quotes for contractions with a keyword search' do
        solr_search.execute base_search_parameters.merge(searchTerms: "the sea's ice")
        expect(rsolr).to have_received(:find).with(
          hash_including('q' => 'the AND sea\'s AND ice'),
          any_args
        )
      end

      it 'preserves quoted strings and operators with a keyword search' do
        solr_search.execute base_search_parameters.merge(searchTerms: 'arctic OR "sea ice"')
        expect(rsolr).to have_received(:find).with(
          hash_including('q' => 'arctic AND sea AND ice'),
          any_args
        )
      end

      it 'escapes parenthesis from phrase strings with a keyword search' do
        solr_search.execute base_search_parameters.merge(searchTerms: '"sea ice (2013-2014)"')
        expect(rsolr).to have_received(:find).with(
          hash_including('q' => 'sea AND ice AND \(2013-2014\)'),
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

      it 'generates filter query with facetFilters parameter' do
        data_center = 'Norwegian%20Meteorological%20Institute'

        fq = [
          'source:NSIDC',
          %({!tag=facet_data_center}facet_data_center:("#{data_center}"))
        ]

        params = {
          facetFilters: %({"facet_data_center":["#{data_center}"]})
        }

        solr_search.execute base_search_parameters.merge(params)

        expect(rsolr).to have_received(:find).with(
          hash_including('fq' => fq),
          any_args
        )
      end

      it 'generates filter query with facetFilters with multiple filters' do
        params = {
          facetFilters: {
            facet_data_center: %w[Norwegian%20Meteorological%20Institute NSIDC],
            facet_temporal_duration: %w[1-5]
          }.to_json
        }
        solr_search.execute(base_search_parameters.merge(params))
        expect(rsolr).to have_received(:find).with(
          hash_including(
            'fq' => [
              'source:NSIDC',
              '{!tag=facet_data_center}facet_data_center:' \
              '("Norwegian%20Meteorological%20Institute" "NSIDC")',
              '{!tag=facet_temporal_duration}facet_temporal_duration:("1-5")'
            ]
          ),
          any_args
        )
      end

      it 'ignores the facetFilter parameter if it is not proper JSON, source is taken by default' do
        params = {
          facetFilters: %({
            "facet_data_center":["Norwegian%20Meteorological%20Institute","NSIDC"],
            $%#$%#% -> "dummy_value"]
          })
        }

        solr_search.execute(base_search_parameters.merge(params))
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
        solr_search.execute(
          base_search_parameters.merge(
            startDate: '2010-01-01',
            endDate: '2011-01-01'
          )
        )
        expect(rsolr).to have_received(:find).with(
          hash_including('q' => 'temporal:[20.1001009,0 TO 90,20.1101011]'),
          any_args
        )
      end
    end

    describe 'search result' do
      it 'sets total results count to number found' do
        result = solr_search.execute base_search_parameters
        expect(result.total_results).to be solr_response['response']['numFound']
      end

      it 'sets set the search dsl to itself' do
        result = solr_search.execute base_search_parameters
        expect(result.search_parameters).to eql base_search_parameters
      end

      it 'sets entities to returned documents' do
        result = solr_search.execute base_search_parameters
        expect(result.entries.length).to be solr_response['response']['docs'].length
      end
    end
  end

  describe NsidcOpenSearch::Dataset::Search::SolrSearchFacets do
    let(:base_search_parameters) do
      {
        source: 'NSIDC',
        count: '25',
        startIndex: '1',
        sortKeys: ''
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
        NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder,
        query_config,
        RSolr::Ext
      )
    end

    before do
      allow(RSolr::Ext).to receive(:connect).and_return(rsolr)
    end

    # TODO: Consider refactoring these tests so that the expects aren't in an external function
    describe 'search request' do
      it 'generates default facet values in facet query' do
        solr_search.execute base_search_parameters
        expect(rsolr).to have_received(:find).with(
          hash_including('facet' => 'true'),
          any_args
        )
      end

      it 'generates facet field string' do
        facet_field = query_config[base_search_parameters[:source]]['facets'].map do |facet|
          "{!ex=#{facet['name']}}#{facet['name']}"
        end

        solr_search.execute(base_search_parameters)
        expect(rsolr).to have_received(:find).with(
          hash_including('facet.field' => facet_field),
          any_args
        )
      end

      it 'generates facet field options override strings' do
        solr_search.execute(base_search_parameters)
        expect(rsolr).to have_received(:find).with(
          hash_including(
            'f.facet_spatial_coverage.facet.sort' => 'count',
            'f.facet_spatial_coverage.facet.mincount' => 0
          ),
          any_args
        )
      end
    end
  end
end
