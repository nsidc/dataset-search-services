require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'search', 'solr_search_dataset')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'model', 'search', 'open_search_response_builder')

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
    {
      'response' =>  {
        'numFound' => 1,
        'start' => 0,
        'docs' => [
          {
              'authoritative_id' => 'abcd',
              'dataset_url' => 'http://nsidc.org/dataset/abcd',
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
          }
        ]
      }
    }
  }

  let(:rsolr) { double('rsolr', find: solr_response) }
  let(:query_config) { YAML.load_file File.join(File.dirname(__FILE__), '..', 'config', 'solr_query_config_test.yml') }
  let(:solr_search) { described_class.new 'localhost:8983', NsidcOpenSearch::Dataset::Search::SolrResultsParser, NsidcOpenSearch::Dataset::Model::Facets::FacetsResponseBuilder, query_config, RSolr::Ext }

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

    # This is basically duplicating the normal query test, verifying that we use the same constraints but using a different parser/builder.

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
