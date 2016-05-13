require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/parsers/solr_results_parser'

describe NsidcOpenSearch::Dataset::Search::SolrResultsParser do
  before :each do
    @solr_response = YAML.load_file(
      File.expand_path('../fixtures/solr_response_with_data_access_url_details.yaml', __FILE__)
    )
    @facet_config = {
      'NSIDC' => {
        'facets' => {
          'name' => 'facet_temporal_duration',
          'sort' => 'defined_sort',
          'sort_order' => ['< 1 year', '1 -4 years', '5 - 9 years', 'Not specified']
        }
      }
    }
  end

  describe 'result entry' do
    before :each do
      @entry = NsidcOpenSearch::Dataset::Search::SolrResultsParser.new(
        response: @solr_response,
        services_config: @facet_config
      ).entries.first
    end

    it 'should set data access urls' do
      expect(@entry.data_access_urls.length).to be 2
    end

    it 'should have a download url with all info needed' do
      expect(@entry.data_access_urls[0].type).to eql 'download'
      expect(@entry.data_access_urls[0].name).to eql 'FTP'
      expect(@entry.data_access_urls[0].description).to eql 'A sample download'
    end

    it 'should have an order url with all info needed' do
      expect(@entry.data_access_urls[1].type).to eql 'order'
      expect(@entry.data_access_urls[1].name).to eql 'Order Data'
      expect(@entry.data_access_urls[1].description).to eql 'Order test link'
    end

    it 'should have two supporting program references' do
      expect(@entry.supporting_programs.length).to be 2
    end

    it 'should have NASA and NOAA supporting programs' do
      expect(@entry.supporting_programs).to include "NOAA @ NSIDC"
      expect(@entry.supporting_programs).to include "NASA NSIDC DAAC"
    end
  end
end
