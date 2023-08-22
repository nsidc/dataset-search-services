# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/parsers/solr_results_parser'

describe NsidcOpenSearch::Dataset::Search::SolrResultsParser do
  let(:solr_response) do
    YAML.load_file(
      File.expand_path('fixtures/solr_response_with_data_access_url_details.yaml', __dir__)
    )
  end
  let(:facet_config) do
    {
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
    let(:entry) do
      described_class.new(
        response: solr_response,
        services_config: facet_config
      ).entries.first
    end

    it 'sets data access urls' do
      expect(entry.data_access_urls.length).to be 3
    end

    it 'has a download url with all info needed' do
      expect(entry.data_access_urls[0].type).to eql 'download'
      expect(entry.data_access_urls[0].name).to eql 'FTP'
      expect(entry.data_access_urls[0].description).to eql 'A sample download'
    end

    it 'has an order url with all info needed' do
      expect(entry.data_access_urls[1].type).to eql 'order'
      expect(entry.data_access_urls[1].name).to eql 'Order Data'
      expect(entry.data_access_urls[1].description).to eql 'Order test link'
    end

    it 'has a documentation url as an information type' do
      expect(entry.data_access_urls[2].type).to eql 'information'
      expect(entry.data_access_urls[2].name).to eql 'Documentation'
    end

    it 'has two supporting program references' do
      expect(entry.supporting_programs.length).to be 2
    end

    it 'has NASA and NOAA supporting programs' do
      expect(entry.supporting_programs).to include 'NOAA @ NSIDC'
      expect(entry.supporting_programs).to include 'NASA NSIDC DAAC'
    end
  end
end
