# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'app')

describe NsidcOpenSearch::App do
  include Rack::Test::Methods

  def app
    @app ||= described_class
  end

  def stubbed_obj(obj = {}, **opts)
    opts.each do |k, v|
      allow(obj).to receive(k).and_return(v)
    end

    obj
  end

  def get_stubbed_facets_from_hash(facets)
    facets.map do |facet|
      fake_facet_values = facet[:items].map do |item|
        stubbed_obj(value: item[:value], hits: item[:hits])
      end

      stubbed_obj(items: fake_facet_values, name: facet[:name])
    end
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

  def default_os_headers; end

  it 'provides dataset OSDD content at its endpoint' do
    get '/OpenSearchDescription', {}, 'HTTP_ACCEPT' => 'application/opensearchdescription+xml'
    expect(last_response).to be_ok
    expect(last_response.header['Content-Type']).to match '^application/opensearchdescription\+xml'
  end

  it 'provides OpenSearch results at its dataset endpoint' do
    solr_response = {
      'response' => {
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

    rsolr = instance_double(RSolr::Ext::Client, find: solr_response)
    allow(RSolr::Ext).to receive(:connect).and_return(rsolr)
    allow(RestClient).to receive(:get).and_return(iso_document_fixture)

    get('/OpenSearch', default_os_query_params,
        'HTTP_ACCEPT' => 'application/atom+xml',
        'X-Requested-With' => 'spec_test')

    expect(last_response).to be_ok
    expect(last_response.header['Content-Type']).to match '^application/atom\+xml'
  end

  # rubocop:disable RSpec/ExampleLength
  it 'provides Facets results at its facets endpoint' do
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
    allow(solr_response).to receive(:facets).and_return(stubbed_facets)

    rsolr = instance_double(RSolr::Ext::Client, find: solr_response)
    allow(RSolr::Ext).to receive(:connect).and_return(rsolr)

    get('/Facets', default_os_query_params,
        'HTTP_ACCEPT' => 'application/nsidcfacets+xml',
        'X-Requested-With' => 'spec_test')
    expect(last_response).to be_ok
    expect(last_response.header['Content-Type']).to match '^application/nsidcfacets\+xml'
  end
  # rubocop:enable RSpec/ExampleLength
end
