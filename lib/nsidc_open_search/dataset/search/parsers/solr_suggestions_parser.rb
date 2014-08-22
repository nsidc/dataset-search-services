require File.join(File.dirname(__FILE__), '..', '..', 'model', 'suggestions', 'suggestion_entry')

module NsidcOpenSearch
  module Dataset
    module Search
      class SolrSuggestionsParser
        attr_reader :entries

        def initialize(options)
          @entries = parse_suggestions(options[:response]['response']['docs'])
        end

        private

        # takes the solr ruby response and returns an array of SuggestionEntries
        def parse_suggestions(solr_suggestions)
          extract_suggestions_array(solr_suggestions).map do |s|
            NsidcOpenSearch::Dataset::Model::Suggestions::SuggestionEntry.new(completion: s)
          end
        end

        # returns a flattened array containing every suggestion (just a string)
        # returned by solr
        def extract_suggestions_array(solr_suggestions)
          arr = solr_suggestions.map do |s|
            s.class == Hash ? s['text_suggest']  : nil
          end
          arr.select { |s| !s.nil? }.flatten
        end
      end
    end
  end
end
