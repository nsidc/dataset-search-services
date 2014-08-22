require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'utils', 'auto_initializer')

module NsidcOpenSearch
  module Dataset
    module Model
      module Search
        class OpenSearchResponseBuilder < AutoInitializer
          attr_accessor :total_results, :entries, :search_parameters

          def to_atom(current_search_url, base_url)
            Tilt.new("#{File.dirname(__FILE__)}/serializers/atom.builder").render(self,
                                                                                  current_search_url: current_search_url, base_url: base_url
            )
          end

          def build_search_url_with_index(current_search_url, startIndex)
            search_url = startIndex.nil? || startIndex == 0 ? nil : current_search_url.clone.gsub!(/startIndex=([^&]+)/, 'startIndex=' + startIndex.to_s)
            search_url
          end
        end
      end
    end
  end
end
