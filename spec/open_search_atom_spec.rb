require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'model', 'search', 'open_search_response_builder')
require File.join(File.dirname(__FILE__), '..', 'lib',  'nsidc_open_search', 'dataset', 'model', 'search', 'result_entry')
require File.join(File.dirname(__FILE__), '..', 'lib',  'nsidc_open_search', 'dataset', 'model', 'search', 'data_access')
require File.join(File.dirname(__FILE__), '..', 'lib',  'nsidc_open_search', 'dataset', 'model', 'search', 'date_range')

describe 'open search response' do
  describe 'result to atom' do
    before :each do
      @result = NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder.new(
        total_results: 100,
        search_parameters: { startIndex: '11', count: '10', searchTerms: 'sea ice' },
        entries: [
          NsidcOpenSearch::Dataset::Model::Search::ResultEntry.new(
            id: 'test',
            dataset_version: '4',
            title: 'test title',
            summary: 'test summary',
            last_revision_date: '2012-01-01',
            url: 'localhost/data/test',
            data_access: [
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(url: 'ftp://some.server', name: 'Test FTP Link', type: 'download'),
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(url: 'http://nsidc.org/order.html', name: 'Test Order Link', type: 'order'),
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(url: 'http://www.ngdc.noaa.gov', name: 'Test Brokered Link', type: 'offlineAccess'),
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(url: 'http://eloka-arctic.org/communities/russia/', name: 'Product Web Site', type: 'information')
            ],
            data_access_urls: ['ftp://some.server'],
            data_centers: ['test center'],
            temporal_coverages: [NsidcOpenSearch::Dataset::Model::Search::DateRange.new(start_date: '2012-01-01', end_date: '2012-02-01')],
            temporal_duration: '31',
            spatial_coverages: ['-53,180,-90,-180', '90,180,60,-180'],
            spatial_area: '314.16'
          )
        ]
      )
    end

    it 'should output a valid atom format' do
      xml = @result.to_atom 'localhost/dataset?searchTerms=sea ice', 'localhost'

      xml.should have_atom_root_element
      xml.should have_atom_namespace
      xml.should have_atom_opensearch_namespace
      xml.should have_an_id
      xml.should have_a_title
      xml.should have_an_updated
      xml.should have_at_least_one_author
      xml.should have_at_least_one_link
      xml.should have_a_first_link
      xml.should have_a_next_link
      xml.should have_a_previous_link
      xml.should have_a_last_link
      xml.should have_a_total_results
      xml.should have_a_start_index
      xml.should have_an_items_per_page
      xml.should have_a_query
      xml.should have_at_least_one_entry_with_an_id
      xml.should have_at_least_one_entry_with_a_dataset_version
      xml.should have_at_least_one_entry_with_a_title
      xml.should have_at_least_one_entry_with_an_updated
      xml.should have_at_least_one_entry_with_a_temporal_duration
      xml.should have_at_least_one_entry_with_a_spatial_area
      xml.should have_at_least_one_entry_with_a_summary
      xml.should have_at_least_one_entry_with_a_catalog_page_link
      xml.should have_at_least_one_entry_with_a_dataset_call_link
      xml.should have_at_least_two_entries_with_a_download_data_rel_link
      xml.should have_at_least_one_entry_with_an_order_data_rel_link
      xml.should have_at_least_one_entry_with_a_external_data_rel_link
      xml.should have_at_least_one_entry_with_an_enclosure_link
      xml.should have_at_least_one_entry_with_at_least_one_data_center
      xml.should have_at_least_one_entry_with_a_date_range
      xml.should have_two_geo_boxes
    end
  end
end
