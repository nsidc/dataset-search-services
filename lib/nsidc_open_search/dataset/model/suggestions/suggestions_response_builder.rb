# frozen_string_literal: true

require 'json'
require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'utils', 'auto_initializer')

module NsidcOpenSearch
  module Dataset
    module Model
      module Suggestions
        class SuggestionsResponseBuilder < AutoInitializer
          attr_accessor :query_string, :entries

          def to_json(*_args)
            [
              query_string,
              entries.map(&:completion)
            ].to_json
          end
        end
      end
    end
  end
end
