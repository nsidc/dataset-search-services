# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/parsers/solr_results_parser'
require_relative 'helpers/solr_facet_response'

describe NsidcOpenSearch::Dataset::Search::SolrResultsParser do
  let(:config) { YAML.load_file(File.expand_path('../config/solr_query_config_test.yml', __dir__)) }
  let(:solr_response) { solr_facet_response }
  let(:facet_result) do
    NsidcOpenSearch::Dataset::Search::SolrFacetsParser.new(
      response: solr_response,
      services_config: config['NSIDC']
    )
  end

  describe 'facet response' do
    it 'sorts facets with a defined sort order' do
      expected = ['< 1 year', '1 - 4 years', '5 - 9 years', '10+ years', 'Not specified']
      expect(facet_result.entries[0].items.map(&:name)).to eql expected
    end

    it 'sorts facets by short name' do
      expect(facet_result.entries[2].items.map(&:name)).to eql [
        ' | a short name',
        'Radar Imaging Systems | IMAGING RADAR SYSTEMS',
        ' | ONE MORE SHORT NAME',
        'Radio Detection | RADAR',
        'Special Sensor Microwave/Imager',
        'Microwave Imager/Sounder | SSMIS'
      ]
    end
  end
end
