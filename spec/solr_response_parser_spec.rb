require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'search', 'parsers', 'solr_results_parser')

describe NsidcOpenSearch::Dataset::Search::SolrResultsParser do
  before :each do
    @solr_response = {
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
            'spatial_coverages' => %w(-180.0,30.98,180.0,90.0 90,90,-90,-90),

            # keep these out of order so sorting can be tested
            'temporal_coverages' => %w(2004-01-01, 1978-10-01,2014-05-23 1978-10-01,2011-12-31 2004-01-01,2005-01-01),

            'distribution_formats' => %w(binary),
            'last_revision_date' => '20130528',
            'temporal_duration' => '33',
            'spatial_area' => '271.83'
          },
          {
            'authoritative_id' => '23456',
            'title' => 'test2'
          }
        ]
      }
    }
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
      @entry = NsidcOpenSearch::Dataset::Search::SolrResultsParser.new(response: @solr_response, services_config: @facet_config).entries.first
    end
    it 'should set id to response authoritative id' do
      expect(@entry.id).to be @solr_response['response']['docs'][0]['authoritative_id']
    end

    it 'should set title to response title' do
      expect(@entry.title).to be @solr_response['response']['docs'][0]['title']
    end

    it 'should set summary' do
      expect(@entry.summary).to eql 'Test Abstract'
    end

    it 'should set parameters' do
      expect(@entry.parameters.length).to be 2
    end

    it 'should set parameter category' do
      expect(@entry.parameters[0].category).to eql 'EARTH SCIENCE'
    end

    it 'should set parameter topic' do
      expect(@entry.parameters[0].topic).to eql 'Cryosphere'
    end

    it 'should set parameter term' do
      expect(@entry.parameters[0].term).to eql 'Snow/Ice'
    end

    it 'should set parameter variable' do
      expect(@entry.parameters[0].variable_1).to eql 'Ice Extent'
    end

    it 'should set parameter name' do
      expect(@entry.parameters[0].name).to eql 'Coverage'
    end

    it 'should set keywords' do
      expect(@entry.keywords.length).to be 3
    end

    it 'should set entry url' do
      expect(@entry.url).to eql 'http://nsidc.org/data/test'
    end

    it 'should set data access urls' do
      expect(@entry.data_access_urls.length).to be 1
    end

    it 'should set authors' do
      expect(@entry.authors.length).to be 2
      expect(@entry.authors).to include('John Doe', 'Jane Doe')
    end

    it 'should set data centers' do
      expect(@entry.data_centers.length).to be 2
      expect(@entry.data_centers).to include('NSIDC', 'NOAA')
    end

    it 'should set spatial coverage' do
      expect(@entry.spatial_coverages.length).to be 2
    end

    it 'should set bounding box coordinates' do
      bbox = @entry.spatial_coverages[0]
      west, south, east, north = bbox.split(',').map(&:to_f)
      expect(west).to eql(-180.0)
      expect(east).to eql 180.0
      expect(north).to eql 90.0
      expect(south).to eql 30.98
    end

    it 'should set temporal coverages' do
      expect(@entry.temporal_coverages.length).to be 4
    end

    it 'should sort the temporal coverages by start_date' do
      expect(@entry.temporal_coverages.first.start_date).to eql Date.parse '1978-10-01'
      expect(@entry.temporal_coverages.last.start_date).to eql Date.parse '2004-01-01'
      expect(@entry.temporal_coverages.last.end_date).to eql nil
    end

    it 'should sort the temporal coverages by end_date if start_date is equal' do
      expect(@entry.temporal_coverages[0].end_date).to eql Date.parse '2011-12-31'
      expect(@entry.temporal_coverages[1].end_date).to eql Date.parse '2014-05-23'
    end

    it 'should treat nil end dates as greater than end dates that exist' do
      expect(@entry.temporal_coverages[2].start_date).to eql Date.parse '2004-01-01'
      expect(@entry.temporal_coverages[2].end_date).to eql Date.parse '2005-01-01'

      expect(@entry.temporal_coverages[3].start_date).to eql Date.parse '2004-01-01'
      expect(@entry.temporal_coverages[3].end_date).to eql nil
    end

    it 'should set date range start and end' do
      dr = @entry.temporal_coverages[0]
      expect(dr.start_date).to eql Date.parse '19781001'
      expect(dr.end_date).to eql Date.parse '20111231'
    end

    it 'should set distribution formats' do
      expect(@entry.distribution_formats.length).to be 1
    end

    it 'should set last revision date' do
      expect(@entry.last_revision_date).to eql Date.parse '20130528'
    end

    it 'should set the temporal duration' do
      expect(@entry.temporal_duration).to eql '33'
    end

    it 'should set the spatial area' do
      expect(@entry.spatial_area).to eql '271.83'
    end
  end
end
