# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'utils', 'auto_initializer')

module NsidcOpenSearch
  module Dataset
    module Model
      module Suggestions
        class SuggestionEntry < AutoInitializer
          attr_accessor :completion

          def initialize(args)
            @value = []
            super args
          end
        end
      end
    end
  end
end
