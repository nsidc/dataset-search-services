require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'utils', 'auto_initializer')

module NsidcOpenSearch
  module Dataset
    module Model
      module Search
        class DateRange <  AutoInitializer
          attr_accessor :start_date, :end_date
        end
      end
    end
  end
end
