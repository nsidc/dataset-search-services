require 'nokogiri'
require File.join(File.dirname(__FILE__), 'matcher_helpers')

RSpec::Matchers.define :have_atom_root_element do
  match_count(1, "#{FEED_SELECTOR}")
end

RSpec::Matchers.define :have_atom_namespace do
  match do |actual|
    xml = get_xml actual
    xml.namespaces.key?('xmlns') && xml.namespaces['xmlns'] == 'http://www.w3.org/2005/Atom'
  end
end

RSpec::Matchers.define :have_atom_opensearch_namespace do
  match do |actual|
    xml = get_xml actual
    xml.namespaces.key?('xmlns:os') && xml.namespaces['xmlns:os'] == 'http://a9.com/-/spec/opensearch/1.1/'
  end
end

RSpec::Matchers.define :have_at_least_one_author do
  match_at_least_one("#{FEED_SELECTOR}/xmlns:author")
end

RSpec::Matchers.define :have_an_id do
  match_count(1, "#{FEED_SELECTOR}/xmlns:id") && match_at_least_one("#{FEED_SELECTOR}/xmlns:id", true)
end

RSpec::Matchers.define :have_at_least_one_link do
  match_at_least_one("#{FEED_SELECTOR}/xmlns:link[@rel='self']")
end

RSpec::Matchers.define :have_a_title do
  match_count(1, "#{FEED_SELECTOR}/xmlns:title") && match_at_least_one("#{FEED_SELECTOR}/xmlns:title", true)
end

RSpec::Matchers.define :have_an_updated do
  match_count(1, "#{FEED_SELECTOR}/xmlns:updated") && match_at_least_one("#{FEED_SELECTOR}/xmlns:updated", true)
end

RSpec::Matchers.define :have_a_total_results do
  match_count(1, "#{FEED_SELECTOR}/os:totalResults") && match_at_least_one("#{FEED_SELECTOR}/os:totalResults", true)
end

RSpec::Matchers.define :have_a_first_link do
  match_at_least_one("#{FEED_SELECTOR}/xmlns:link[@rel='first']")
end

RSpec::Matchers.define :have_a_previous_link do
  match_at_least_one("#{FEED_SELECTOR}/xmlns:link[@rel='previous']")
end

RSpec::Matchers.define :have_a_next_link do
  match_at_least_one("#{FEED_SELECTOR}/xmlns:link[@rel='next']")
end

RSpec::Matchers.define :have_a_last_link do
  match_at_least_one("#{FEED_SELECTOR}/xmlns:link[@rel='last']")
end

RSpec::Matchers.define :have_a_start_index do
  match_count(1, "#{FEED_SELECTOR}/os:startIndex") && match_at_least_one("#{FEED_SELECTOR}/os:startIndex", true)
end

RSpec::Matchers.define :have_an_items_per_page do
  match_count(1, "#{FEED_SELECTOR}/os:itemsPerPage") && match_at_least_one("#{FEED_SELECTOR}/os:itemsPerPage", true)
end

RSpec::Matchers.define :have_a_query do
  match_count(1, "#{FEED_SELECTOR}/os:query")
end

RSpec::Matchers.define :have_at_least_one_link do
  match_at_least_one("#{FEED_SELECTOR}/xmlns:link")
end

RSpec::Matchers.define :have_at_least_one_entry_with_an_id do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:id")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_dataset_version do
  match_at_least_one("#{ENTRY_SELECTOR}/nsidc:datasetVersion")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_title do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:title")
end

RSpec::Matchers.define :have_at_least_one_entry_with_an_updated do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:updated")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_temporal_duration do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:temporal_duration")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_spatial_area do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:spatial_area")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_summary do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:summary")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_catalog_page_link do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:link[@rel='describedBy' and @type='text/html']")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_dataset_call_link do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:link[@rel='describedBy' and @type='application/atom+xml']")
end

RSpec::Matchers.define :have_at_least_two_entries_with_a_download_data_rel_link do
  match_at_least_two("#{ENTRY_SELECTOR}/xmlns:link[@rel='download-data']")
end

RSpec::Matchers.define :have_at_least_one_entry_with_an_order_data_rel_link do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:link[@rel='order-data']")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_external_data_rel_link do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:link[@rel='external-data']")
end

RSpec::Matchers.define :have_at_least_one_entry_with_an_enclosure_link do
  match_at_least_one("#{ENTRY_SELECTOR}/xmlns:link[@rel='enclosure']")
end

RSpec::Matchers.define :have_at_least_one_entry_with_at_least_one_data_center do
  match_at_least_one("#{ENTRY_SELECTOR}/nsidc:dataCenter")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_date_range do
  match_at_least_one("#{ENTRY_SELECTOR}/dc:date")
end

RSpec::Matchers.define :have_two_geo_boxes do
  match_at_least_two("#{ENTRY_SELECTOR}/georss:box")
end

RSpec::Matchers.define :have_at_least_one_entry_with_a_supporting_programs do
  match_at_least_one("#{ENTRY_SELECTOR}/nsidc:supportingProgram")
end

RSpec::Matchers.define :have_three_facets do
  match_count(3, "#{FACET_SELECTOR}")
end

private

FEED_SELECTOR =  '/xmlns:feed'
ENTRY_SELECTOR = '/xmlns:feed/xmlns:entry'
FACET_SELECTOR = '/xmlns:feed/nsidc:facet'

def match_count(count, selector)
  match do |actual|
    xml = get_xml actual
    xml.xpath(selector).length == count
  end
end

def match_at_least_one(selector, text = false)
  if text
    match do |actual|
      xml = get_xml actual
      xml.xpath(selector).text.length >= 1
    end
  else
    match do |actual|
      xml = get_xml actual
      xml.xpath(selector).length >= 1
    end
  end
end

def match_at_least_two(selector)
  match do |actual|
    xml = get_xml actual
    xml.xpath(selector).length >= 2
  end
end
