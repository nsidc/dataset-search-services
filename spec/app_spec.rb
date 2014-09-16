require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'app')
require 'libre_metrics_client'

describe 'Nsidc OpenSearch App' do
  include Rack::Test::Methods

  def app
    @app ||= NsidcOpenSearch::App
  end

  def get_stubbed_facets_from_hash(facets)
    facet_stubs = []

    facets.each do |facet|
      fake_facet = {}
      fake_facet_values = []

      facet[:items].each do |item|
        fake_facet_value = {}

        fake_facet_value.stub(:value).and_return(item[:value])
        fake_facet_value.stub(:hits).and_return(item[:hits])

        fake_facet_values.push(fake_facet_value)
      end

      fake_facet.stub(:items).and_return(fake_facet_values)
      fake_facet.stub(:name).and_return(facet[:name])

      facet_stubs.push(fake_facet)
    end

    facet_stubs
  end

  def default_os_query_params
    {
      searchTerms: 'sea ice',
      spatial: '',
      startDate: '',
      endDate: '',
      startIndex: 1,
      count: 25,
      source: '',
      facetFilters: '',
      sortKeys: 'score,,0'
    }
  end

  def default_os_headers
  end

  it 'should provide dataset OSDD content at its endpoint' do
    get '/OpenSearchDescription', {},  'HTTP_ACCEPT' => 'application/opensearchdescription+xml'
    last_response.should be_ok
    last_response.header['Content-Type'].should match '^application/opensearchdescription\+xml'
  end

  it 'should provide OpenSearch results at its dataset endpoint' do
    solr_response = {
      'response' =>  {
        'numFound' => 1,
        'docs' => [
          {
            'authoritative_id' => '12345',
            'title' => 'test',
            'iso' => iso_document_fixture
          }
        ]
      }
    }

    rsolr = double('rsolr', find: solr_response)
    RSolr::Ext.stub(:connect).and_return(rsolr)
    RestClient.stub(:get).and_return(iso_document_fixture)

    get('/OpenSearch', default_os_query_params,
        'HTTP_ACCEPT' => 'application/atom+xml',
        'X-Requested-With' => 'spec_test'
       )

    last_response.should be_ok
    last_response.header['Content-Type'].should match '^application/atom\+xml'
  end

  it 'should provide Facets results at its facets endpoint' do

    facets_hash = [
      {
        name: 'data_center',
        items: [
          {
            value: 'nsidc',
            hits: '234'
          }
        ]
      },

      {
        name: 'temporal_duration',
        items: [
          {
            value: '1-5',
            hits: '123'
          },
          {
            value: '5-10',
            hits: '77'
          }
        ]
      },

      {
        name: 'author',
        items: [
          value: 'Mark Serreze',
          hits: '25'
        ]
      }
    ]

    stubbed_facets = get_stubbed_facets_from_hash(facets_hash)

    solr_response = {}
    solr_response.stub(:facets).and_return(stubbed_facets)

    rsolr = double('rsolr', find: solr_response)
    RSolr::Ext.stub(:connect).and_return(rsolr)

    get('/Facets', default_os_query_params,
        'HTTP_ACCEPT' => 'application/nsidcfacets+xml',
        'X-Requested-With' => 'spec_test'
       )
    last_response.should be_ok
    last_response.header['Content-Type'].should match '^application/nsidcfacets\+xml'
  end

end
