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
      @entry.id.should be @solr_response['response']['docs'][0]['authoritative_id']
    end

    it 'should set title to response title' do
      @entry.title.should be @solr_response['response']['docs'][0]['title']
    end

    it 'should set summary' do
      @entry.summary.should eql 'Test Abstract'
    end

    it 'should set parameters' do
      @entry.parameters.length.should be 2
    end

    it 'should set parameter category' do
      @entry.parameters[0].category.should eql 'EARTH SCIENCE'
    end

    it 'should set parameter topic' do
      @entry.parameters[0].topic.should eql 'Cryosphere'
    end

    it 'should set parameter term' do
      @entry.parameters[0].term.should eql 'Snow/Ice'
    end

    it 'should set parameter variable' do
      @entry.parameters[0].variable_1.should eql 'Ice Extent'
    end

    it 'should set parameter name' do
      @entry.parameters[0].name.should eql 'Coverage'
    end

    it 'should set keywords' do
      @entry.keywords.length.should be 3
    end

    it 'should set entry url' do
      @entry.url.should eql 'http://nsidc.org/data/test'
    end

    it 'should set data access urls' do
      @entry.data_access_urls.length.should be 1
    end

    it 'should set authors' do
      @entry.authors.length.should be 2
      @entry.authors.should include('John Doe', 'Jane Doe')
    end

    it 'should set data centers' do
      @entry.data_centers.length.should be 2
      @entry.data_centers.should include('NSIDC', 'NOAA')
    end

    it 'should set spatial coverage' do
      @entry.spatial_coverages.length.should be 2
    end

    it 'should set bounding box coordinates' do
      bbox = @entry.spatial_coverages[0]
      west, south, east, north = bbox.split(',').map { |c| c.to_f }
      west.should eql(-180.0)
      east.should eql 180.0
      north.should eql 90.0
      south.should eql 30.98
    end

    it 'should set temporal coverages' do
      @entry.temporal_coverages.length.should be 4
    end

    it 'should sort the temporal coverages by start_date' do
      @entry.temporal_coverages.first.start_date.should eql Date.parse '1978-10-01'
      @entry.temporal_coverages.last.start_date.should eql Date.parse '2004-01-01'
      @entry.temporal_coverages.last.end_date.should eql nil
    end

    it 'should sort the temporal coverages by end_date if start_date is equal' do
      @entry.temporal_coverages[0].end_date.should eql Date.parse '2011-12-31'
      @entry.temporal_coverages[1].end_date.should eql Date.parse '2014-05-23'
    end

    it 'should treat nil end dates as greater than end dates that exist' do
      @entry.temporal_coverages[2].start_date.should eql Date.parse '2004-01-01'
      @entry.temporal_coverages[2].end_date.should eql Date.parse '2005-01-01'

      @entry.temporal_coverages[3].start_date.should eql Date.parse '2004-01-01'
      @entry.temporal_coverages[3].end_date.should eql nil
    end

    it 'should set date range start and end' do
      dr = @entry.temporal_coverages[0]
      dr.start_date.should eql Date.parse '19781001'
      dr.end_date.should eql Date.parse '20111231'
    end

    it 'should set distribution formats' do
      @entry.distribution_formats.length.should be 1
    end

    it 'should set last revision date' do
      @entry.last_revision_date.should eql Date.parse '20130528'
    end

    it 'should set the temporal duration' do
      @entry.temporal_duration.should eql '33'
    end

    it 'should set the spatial area' do
      @entry.spatial_area.should eql '271.83'
    end
  end
end
