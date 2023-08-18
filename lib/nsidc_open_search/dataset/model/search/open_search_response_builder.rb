# frozen_string_literal: true

require_relative '../../../../utils/auto_initializer'

module NsidcOpenSearch
  module Dataset
    module Model
      module Search
        class OpenSearchResponseBuilder < AutoInitializer
          attr_accessor :total_results, :entries, :search_parameters

          def to_atom(current_search_url, base_url)
            Tilt.new("#{File.dirname(__FILE__)}/serializers/atom.builder").render(
              self,
              current_search_url: current_search_url, base_url: base_url
            )
          end

          def build_search_url_with_index(current_search_url, start_index)
            return if start_index.nil? || start_index.zero?

            current_search_url.dup.gsub!(/startIndex=([^&]+)/, "startIndex=#{start_index}".dup)
          end
        end
      end
    end
  end
end
