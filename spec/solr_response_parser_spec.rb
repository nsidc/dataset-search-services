# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/parsers/solr_results_parser'

describe NsidcOpenSearch::Dataset::Search::SolrResultsParser do
  let(:solr_response) do
    YAML.load_file(
      File.expand_path('fixtures/solr_response_unordered_temporal.yaml', __dir__)
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

    it 'sets id to response authoritative id' do
      expect(entry.id).to be solr_response['response']['docs'][0]['authoritative_id']
    end

    it 'sets title to response title' do
      expect(entry.title).to be solr_response['response']['docs'][0]['title']
    end

    it 'sets summary' do
      expect(entry.summary).to eql 'Test Abstract'
    end

    it 'sets parameters' do
      expect(entry.parameters.length).to be 2
    end

    it 'sets parameter category' do
      expect(entry.parameters[0].category).to eql 'EARTH SCIENCE'
    end

    it 'sets parameter topic' do
      expect(entry.parameters[0].topic).to eql 'Cryosphere'
    end

    it 'sets parameter term' do
      expect(entry.parameters[0].term).to eql 'Snow/Ice'
    end

    it 'sets parameter variable' do
      expect(entry.parameters[0].variable_1).to eql 'Ice Extent'
    end

    it 'sets parameter name' do
      expect(entry.parameters[0].name).to eql 'Coverage'
    end

    it 'sets keywords' do
      expect(entry.keywords.length).to be 3
    end

    it 'sets entry url' do
      expect(entry.url).to eql 'http://nsidc.org/data/test'
    end

    it 'sets data access urls' do
      expect(entry.data_access_urls.length).to be 1
    end

    it 'sets authors' do
      expect(entry.authors.length).to be 2
      expect(entry.authors).to include('John Doe', 'Jane Doe')
    end

    it 'sets data centers' do
      expect(entry.data_centers.length).to be 2
      expect(entry.data_centers).to include('NSIDC', 'NOAA')
    end

    it 'sets spatial coverage' do
      expect(entry.spatial_coverages.length).to be 2
    end

    it 'sets bounding box coordinates' do
      bbox = entry.spatial_coverages[0]
      west, south, east, north = bbox.split(',').map(&:to_f)
      expect(west).to be(-180.0)
      expect(east).to be 180.0
      expect(north).to be 90.0
      expect(south).to be 30.98
    end

    it 'sets temporal coverages' do
      expect(entry.temporal_coverages.length).to be 4
    end

    it 'sorts the temporal coverages by start_date' do
      expect(entry.temporal_coverages.first.start_date).to eql Date.parse '1978-10-01'
      expect(entry.temporal_coverages.last.start_date).to eql Date.parse '2004-01-01'
      expect(entry.temporal_coverages.last.end_date).to be_nil
    end

    it 'sorts the temporal coverages by end_date if start_date is equal' do
      expect(entry.temporal_coverages[0].end_date).to eql Date.parse '2011-12-31'
      expect(entry.temporal_coverages[1].end_date).to eql Date.parse '2014-05-23'
    end

    it 'treats nil end dates as greater than end dates that exist' do
      expect(entry.temporal_coverages[2].start_date).to eql Date.parse '2004-01-01'
      expect(entry.temporal_coverages[2].end_date).to eql Date.parse '2005-01-01'

      expect(entry.temporal_coverages[3].start_date).to eql Date.parse '2004-01-01'
      expect(entry.temporal_coverages[3].end_date).to be_nil
    end

    it 'sets date range start and end' do
      dr = entry.temporal_coverages[0]
      expect(dr.start_date).to eql Date.parse '19781001'
      expect(dr.end_date).to eql Date.parse '20111231'
    end

    it 'sets distribution formats' do
      expect(entry.distribution_formats.length).to be 1
    end

    it 'sets last revision date' do
      expect(entry.last_revision_date).to eql Date.parse '20130528'
    end

    it 'sets the temporal duration' do
      expect(entry.temporal_duration).to eql '33'
    end

    it 'sets the spatial area' do
      expect(entry.spatial_area).to eql '271.83'
    end
  end
end
