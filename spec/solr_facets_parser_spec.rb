require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'search', 'parsers', 'solr_results_parser')
require File.join(File.dirname(__FILE__), 'helpers/solr_facet_response.rb')

describe NsidcOpenSearch::Dataset::Search::SolrResultsParser do
  before :each do
    @config = YAML.load_file File.join(File.dirname(__FILE__), '..', 'config', 'solr_query_config_test.yml')
    @solr_response = solr_facet_response
    @facet_result = NsidcOpenSearch::Dataset::Search::SolrFacetsParser.new(response: @solr_response, services_config: @config['NSIDC'])
  end

  describe 'facet response' do
    it 'should sort facets with a defined sort order' do
      expect(@facet_result.entries[0].items.map { |item| item.name }).to eql ['< 1 year', '1 - 4 years', '5 - 9 years', '10+ years', 'Not specified']
    end

    it 'should sort facets by short name' do
      expect(@facet_result.entries[2].items.map { |item| item.name }).to eql [
        'Imaging Radar Systems, Real and Synthetic Aperture | IMAGING RADAR SYSTEMS',
        'Radio Detection and Ranging | RADAR',
        'Special Sensor Microwave Imager/Sounder | SSMIS',
        ' | no long name',
        'Special Sensor Microwave/Imager'
      ]
    end
  end
end
