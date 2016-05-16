require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/model/search/open_search_response_builder'
require_relative '../lib/nsidc_open_search/dataset/model/search/result_entry'
require_relative '../lib/nsidc_open_search/dataset/model/search/data_access'
require_relative '../lib/nsidc_open_search/dataset/model/search/date_range'

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
            data_access_urls: [
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(
                url: 'ftp://some.server',
                name: 'Test FTP Link',
                type: 'download'
              ),
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(
                url: 'http://nsidc.org/order.html',
                name: 'Test Order Link',
                type: 'order'
              ),
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(
                url: 'http://www.ngdc.noaa.gov',
                name: 'Test Brokered Link',
                type: 'offlineAccess'
              ),
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(
                url: 'http://eloka-arctic.org/communities/russia/',
                name: 'Product Web Site',
                type: 'information'
              ),
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(
                url: 'http://some.server/with/documentation',
                name: 'Documentation',
                type: 'information'
              ),
              NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(
                url: 'ftp://some.other.server'
              )
            ],
            data_centers: ['test center'],

            temporal_coverages: [
              NsidcOpenSearch::Dataset::Model::Search::DateRange.new(
                start_date: '2012-01-01',
                end_date: '2012-02-01'
              )
            ],
            temporal_duration: '31',
            spatial_coverages: ['-53,180,-90,-180', '90,180,60,-180'],
            spatial_area: '314.16',
            supporting_programs: ['NASA NSIDC DAAC']
          )
        ]
      )
    end

    it 'should output a valid atom format' do
      xml = @result.to_atom 'localhost/dataset?searchTerms=sea ice', 'localhost'

      expect(xml).to have_atom_root_element
      expect(xml).to have_atom_namespace
      expect(xml).to have_atom_opensearch_namespace
      expect(xml).to have_an_id
      expect(xml).to have_a_title
      expect(xml).to have_an_updated
      expect(xml).to have_at_least_one_author
      expect(xml).to have_at_least_one_link
      expect(xml).to have_a_first_link
      expect(xml).to have_a_next_link
      expect(xml).to have_a_previous_link
      expect(xml).to have_a_last_link
      expect(xml).to have_a_total_results
      expect(xml).to have_a_start_index
      expect(xml).to have_an_items_per_page
      expect(xml).to have_a_query
      expect(xml).to have_at_least_one_entry_with_an_id
      expect(xml).to have_at_least_one_entry_with_a_dataset_version
      expect(xml).to have_at_least_one_entry_with_a_title
      expect(xml).to have_at_least_one_entry_with_an_updated
      expect(xml).to have_at_least_one_entry_with_a_temporal_duration
      expect(xml).to have_at_least_one_entry_with_a_spatial_area
      expect(xml).to have_at_least_one_entry_with_a_summary
      expect(xml).to have_at_least_one_entry_with_a_catalog_page_link
      expect(xml).to have_at_least_one_entry_with_a_dataset_call_link
      expect(xml).to have_at_least_two_entries_with_a_download_data_rel_link
      expect(xml).to have_at_least_one_entry_with_an_order_data_rel_link
      expect(xml).to have_at_least_one_entry_with_a_external_data_rel_link
      expect(xml).to have_at_least_one_entry_with_a_documentation_link_with_no_rel
      expect(xml).to have_at_least_one_entry_with_an_enclosure_link
      expect(xml).to have_at_least_one_entry_with_at_least_one_data_center
      expect(xml).to have_at_least_one_entry_with_a_date_range
      expect(xml).to have_at_least_one_entry_with_a_supporting_programs
      expect(xml).to have_two_geo_boxes
    end
  end
end
