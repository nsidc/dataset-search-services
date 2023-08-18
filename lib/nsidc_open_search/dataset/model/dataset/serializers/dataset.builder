# frozen_string_literal: true

require_relative '../../../../routes'
require_relative '../../../search/definitions/definition'

# rubocop:disable Metrics/BlockLength
xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom',
         'xmlns:os' => 'http://a9.com/-/spec/opensearch/1.1/',
         'xmlns:dif' => 'http://gcmd.gsfc.nasa.gov/Aboutus/xml/dif/',
         'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
         'xmlns:nsidc' => 'http://nsidc.org/ns/opensearch/1.1/',
         'xmlns:time' => 'http://a9.com/-/opensearch/extensions/time/1.0/',
         'xmlns:geo' => 'http://a9.com/-/opensearch/extensions/geo/1.0/',
         'xmlns:georss' => 'http://www.georss.org/georss' do
  xml.title 'NSIDC dataset search results'
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
  xml.os :startIndex, search_parameters[:startIndex]
  xml.os :itemsPerPage, search_parameters[:count]

  query_attrs = { 'role' => 'request' }
  search_parameters.each do |k, v|
    query_attrs[NsidcOpenSearch::Dataset::Search::Definition.send(k).replacement] = v
  end
  xml.os :query, query_attrs

  entries.each do |e|
    xml.entry do
      xml.id e.id # this is an optional field in iso, what should we do if it is empty?
      xml.nsidc :datasetVersion, e.dataset_version
      xml.title e.title
      xml.updated e.last_revision_date
      xml.summary e.summary
      e.spatial_coverages.each do |sc|
        xml.georss :box, sc
      end
      e.temporal_coverages.each do |t|
        xml.dc :date, "#{t.start_date}/#{t.end_date}"
      end
      xml.link 'href' => e.url, 'rel' => 'describedBy', 'type' => 'text/html'

      e.data_access.each do |u|
        rel = ''

        case u.type
        when 'download'
          rel = 'download-data'
        when 'order'
          rel = 'order-data'
        when 'offlineAccess'
          rel = 'external-data'
        end

        # if only a URL is present, it's an enclosure
        if u.rel == '' && (u.title.nil? || u.title == '') &&
           (u.description.nil? || u.description == '')
          rel = 'enclosure'
        end

        xml.link(
          'href' => u.url,
          'rel' => rel,
          'title' => u.name,
          'nsidc:description' => u.description
        )
      end

      xml.nsidc :datasetId, e.id

      e.authors.each do |a|
        xml.author do
          xml.name a
        end
      end

      e.data_centers.each do |d|
        xml.nsidc :dataCenter, d
      end

      e.supporting_programs.each do |s|
        xml.nsidc :supportingProgram, s
      end

      e.parameters.each do |p|
        xml.dif :Parameters do
          xml.dif :Category, p.category
          xml.dif :Topic, p.topic
          xml.dif :Term, p.term
          xml.dif :Variable_Level_1, p.variable_1
          xml.dif :Variable_Level_2, p.variable_2
          xml.dif :Variable_Level_3, p.variable_3
          xml.dif :Detailed_Variable, p.name
        end
      end

      e.keywords.each do |k|
        xml.dif :Keyword, k
      end

      e.distribution_formats.each do |d|
        xml.dif :Distribution do
          xml.dif :Distribution_Format, d
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
