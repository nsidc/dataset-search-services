require_relative '../../../../utils/auto_initializer'

module NsidcOpenSearch
  module Dataset
    module Model
      module Dataset
        class DatasetResponseBuilder < AutoInitializer
          attr_accessor :total_results, :entries, :search_parameters

          def to_atom(current_search_url, base_url)
            Tilt.new("#{File.dirname(__FILE__)}/serializers/dataset.builder").render(
              self,
              current_search_url: current_search_url,
              base_url: base_url
            )
          end
        end
      end
    end
  end
end
