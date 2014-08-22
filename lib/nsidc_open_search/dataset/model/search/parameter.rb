require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'utils', 'auto_initializer')

module NsidcOpenSearch
  module Dataset
    module Model
      module Search
        class Parameter <  AutoInitializer
          attr_accessor :category, :topic, :term, :variable_1, :variable_2, :variable_3, :name
        end
      end
    end
  end
end
