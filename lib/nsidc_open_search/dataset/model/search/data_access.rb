# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'utils', 'auto_initializer')

module NsidcOpenSearch
  module Dataset
    module Model
      module Search
        class DataAccess < AutoInitializer
          attr_accessor :url, :name, :description, :type
        end
      end
    end
  end
end
