require File.join(File.dirname(__FILE__), '..', 'open_search_dsl', 'open_search_description_document')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'definitions', 'definition')
require File.join(File.dirname(__FILE__), 'routes')

module NsidcOpenSearch
  module DatasetOsdd
    def self.new(base_url)
      dataset_definition = NsidcOpenSearch::Dataset::Search::Definition
      suggest_definition = NsidcOpenSearch::Dataset::Search::DefinitionSuggest

      OpenSearchDsl::OpenSearchDescriptionDocument.new do
        namespace 'time', 'http://a9.com/-/opensearch/extensions/time/1.0/'
        namespace 'geo', 'http://a9.com/-/opensearch/extensions/geo/1.0/'
        namespace 'nsidc', 'http://nsidc.org/ns/opensearch/1.1/'
        short_name 'NSIDC Data Set OpenSearch Service'
        long_name 'Data set level OpenSearch interface for nsidc.org'
        description 'OpenSearch description document that describes how to query our server for data set level information. This service is currently in incubation; it is publicly accessible but the interface is not yet stable and custom elements are not documented.'
        tags 'nsidc.org opensearch search data set geospatial temporal parameter'
        contact 'nsidc@nsidc.org'
        language 'en-us'
        input_encoding 'UTF-8'
        output_encoding 'UTF-8'
        attribution '&#169; 2011 National Snow and Ice Data Center.'
        image 'http://nsidc.org/favicon.ico', 16, 16, 'image/jpeg'
        image 'http://nsidc.org/images/logo_nsidc_76x60.jpg', 60, 75, 'image/jpeg'

        dataset_definition.valids.each do |terms|
          url do
            type 'application/atom+xml'
            base_url "#{base_url}#{NsidcOpenSearch::Routes.named(:dataset_search)}"
            terms[:required].each do |t|
              parameter t.to_s, dataset_definition.send(t).replacement, true
            end
            terms[:optional].each do |t|
              parameter t.to_s, dataset_definition.send(t).replacement, false
            end
          end

          url do
            type 'application/nsidc:facets+xml'
            base_url "#{base_url}#{NsidcOpenSearch::Routes.named(:dataset_facets)}"
            terms[:required].each do |t|
              parameter t.to_s, dataset_definition.send(t).replacement, true
            end
            terms[:optional].each do |t|
              parameter t.to_s, dataset_definition.send(t).replacement, false
            end
          end

          url do
            type 'application/atom+xml'
            base_url "#{base_url}/id/{nsidc:authoritativeId}"
          end

          query do
            terms.values.flatten.each do |t|
              parameter dataset_definition.send(t).replacement, dataset_definition.send(t).example
            end
          end
        end

        suggest_definition.valids.each do |terms|
          url do
            type 'application/x-suggestions+json'
            base_url "#{base_url}#{NsidcOpenSearch::Routes.named(:dataset_suggestions)}"
            terms[:required].each do |t|
              parameter t.to_s, suggest_definition.send(t).replacement, true
            end
            terms[:optional].each do |t|
              parameter t.to_s, suggest_definition.send(t).replacement, false
            end
          end

          query do
            terms.values.flatten.each do |t|
              parameter suggest_definition.send(t).replacement, suggest_definition.send(t).example
            end
          end
        end
      end
    end
  end
end
