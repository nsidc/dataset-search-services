require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'search', 'solr_search_dataset')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'model', 'search', 'open_search_response_builder')

describe NsidcOpenSearch::Dataset::Search::SolrSearchDataset do
  let(:default_search_expectations) {
    {
      'q' => '*:*',
      'qf' => 'title^15 parameters^3 summary^5 topics keywords^3 platforms^2 sensors^2 normalized_authoritative_id^100 authors',
      'pf' => 'title^25 parameters^5 summary^25 keywords^5',
      'ps' => 1,
      'rows' => 25,
      'bq' => 'brokered:false^100 published_date:[NOW-2YEARS/DAY TO NOW/DAY]^15',
      'boost' => 'product(popularity,query({!type=edismax qf=$qf pf=$pf ps=$ps bq=$bq bf=sum(1,product(tan(div(popularity,8)),50))^55 v=$q boost=}))',
      'sort' => 'score desc'
    }
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
    {
      'response' =>  {
        'numFound' => 2,
        'start' => 0,
        'docs' => [
          {
              'authoritative_id' => '12345',
              'dataset_url' => 'http://nsidc.org/data/test',
              'title' => 'test',
              'summary' => 'Test Abstract',
              'full_parameters' => ['EARTH SCIENCE > Cryosphere > Snow/Ice > Ice Extent > Coverage', 'EARTH SCIENCE > Terrestrial Hydrosphere > Snow/Ice > Ice Extent'],
              'keywords' => %w(k1 k2 k3),
              'data_access_urls' => %w(ftp://nsidc.org/data/test),
              'authors' => ['John Doe', 'Jane Doe'],
              'data_centers' => %w(NSIDC NOAA),
              'supporting_programs' => ['Making Earth System Data Records for Use in Research Environments', 'NASA DAAC at the National Snow and Ice Data Center'],
              'spatial_coverages' => %w(-180.0,30.98,180.0,90.0 90,90,-90,-90),
              'temporal_coverages' => %w(1978-10-01,2011-12-31 2004-01-01,),
              'distribution_formats' => %w(binary),
              'last_revision_date' => '20130528'
          },
          {
              'authoritative_id' => '23456',
              'title' => 'test2'
          }
        ]
      }
    }
  }

  let(:rsolr) { double('rsolr', find: solr_response) }

  let(:query_config) { YAML.load_file File.join(File.dirname(__FILE__), '..', 'config', 'solr_query_config_test.yml') }

  let(:solr_search) { described_class.new 'localhost:8983', NsidcOpenSearch::Dataset::Search::SolrResultsParser, NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder, query_config, RSolr::Ext }

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

    it 'generates a sort field containing the indexed field to sort on and which direction to sort' do
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

    it 'strips single character words/numbers from phrase strings with a keyword search because single characters are not indexed' do
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
      get_should_receive_expectations 'fq' => %w(source:NSIDC {!tag=facet_data_center}facet_data_center:("Norwegian%20Meteorological%20Institute"))
      solr_search.execute base_search_parameters.merge(facetFilters: '{"facet_data_center":["Norwegian%20Meteorological%20Institute"]}')
    end

    it 'generates filter query with facetFilters with multiple filters' do
      get_should_receive_expectations 'fq' => ['source:NSIDC', '{!tag=facet_data_center}facet_data_center:("Norwegian%20Meteorological%20Institute" "NSIDC")', '{!tag=facet_temporal_duration}facet_temporal_duration:("1-5")']
      solr_search.execute base_search_parameters.merge(facetFilters: '{"facet_data_center":["Norwegian%20Meteorological%20Institute","NSIDC"],"facet_temporal_duration":["1-5"]}')
    end

    it 'ignores the facetFilter parameter if it is not proper JSON, source is taken by default' do
      get_should_receive_expectations 'fq' => %w(source:NSIDC)
      solr_search.execute base_search_parameters.merge(facetFilters: '{"facet_data_center":["Norwegian%20Meteorological%20Institute","NSIDC"], $%#$%#% -> "dummy_value"]}')
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
      solr_search.execute base_search_parameters.merge(startDate: '2010-01-01', endDate: '2011-01-01')
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
    {
      'response' =>  {
        'numFound' => 2,
        'start' => 0,
        'docs' => [
          {
              'authoritative_id' => '12345',
              'dataset_url' => 'http://nsidc.org/data/test',
              'title' => 'test',
              'summary' => 'Test Abstract',
              'full_parameters' => ['EARTH SCIENCE > Cryosphere > Snow/Ice > Ice Extent > Coverage', 'EARTH SCIENCE > Terrestrial Hydrosphere > Snow/Ice > Ice Extent'],
              'keywords' => %w(k1 k2 k3),
              'data_access_urls' => %w(ftp://nsidc.org/data/test),
              'authors' => ['John Doe', 'Jane Doe'],
              'data_centers' => %w(NSIDC NOAA),
              'supporting_programs' => ['Making Earth System Data Records for Use in Research Environments', 'NASA DAAC at the National Snow and Ice Data Center'],
              'spatial_coverages' => %w(-180.0,30.98,180.0,90.0 90,90,-90,-90),
              'temporal_coverages' => %w(1978-10-01,2011-12-31 2004-01-01,),
              'distribution_formats' => %w(binary),
              'last_revision_date' => '20130528'
          },
          {
              'authoritative_id' => '23456',
              'title' => 'test2'
          }
        ]
      }
    }
  }

  let(:rsolr) { double('rsolr', find: solr_response) }

  let(:query_config) { YAML.load_file File.join(File.dirname(__FILE__), '..', 'config', 'solr_query_config_test.yml') }

  let(:solr_search) { described_class.new 'localhost:8983', NsidcOpenSearch::Dataset::Search::SolrResultsParser, NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder, query_config, RSolr::Ext }

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
      get_should_receive_expectations 'facet.field' => query_config[base_search_parameters[:source]]['facets'].map { |facet| "{!ex=#{facet['name']}}#{facet['name']}" }
      solr_search.execute base_search_parameters
    end

    it 'generates facet field options override strings' do
      get_should_receive_expectations 'f.facet_spatial_coverage.facet.sort' => 'count', 'f.facet_spatial_coverage.facet.mincount' => 0
      solr_search.execute base_search_parameters
    end

  end
end
