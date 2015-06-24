require_relative '../../../../routes'
require_relative '../../../search/definitions/definition'

xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom',
         'xmlns:os' => 'http://a9.com/-/spec/opensearch/1.1/',
         'xmlns:dif' => 'http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/',
         'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
         'xmlns:nsidc' =>  'http://nsidc.org/ns/opensearch/1.1/',
         'xmlns:time' => 'http://a9.com/-/opensearch/extensions/time/1.0/',
         'xmlns:geo' => 'http://a9.com/-/opensearch/extensions/geo/1.0/',
         'xmlns:georss' => 'http://www.georss.org/georss' do
  xml.title 'NSIDC facets results'
  xml.updated DateTime.now.iso8601(3)
  xml.author do
    xml.name 'nsidc.org'
    xml.email 'nsidc@nsidc.org'
    xml.uri 'http://nsidc.org'
  end
  xml.id current_search_url
  xml.link 'href' => current_search_url, 'rel' => 'self'
  xml.link(
    'href' => "#{base_url}#{NsidcOpenSearch::Routes.named(:dataset_osdd)}",
    'rel' => 'search',
    'type' => 'application/opensearchdescription+xml'
  )
  xml.os :totalResults, total_results

  query_attrs = { 'role' => 'request' }
  search_parameters.each do |k, v|
    query_attrs[NsidcOpenSearch::Dataset::Search::Definition.send(k).replacement] = v
  end
  xml.os :query, query_attrs

  entries.each do |facet|
    xml.nsidc :facet, 'name' => facet.name do
      facet.items.each do |f|
        xml.nsidc :facet_value, 'name' => f.name, 'hits' => f.hits
      end
    end
  end
end
