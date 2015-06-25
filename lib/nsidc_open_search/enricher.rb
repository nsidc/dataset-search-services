require 'peach'
require_relative '../utils/class_module'

module NsidcOpenSearch
  module Enricher
    extend ClassModule

    DEFAULT_THREAD_COUNT = 5

    module ClassMethods
      def entry_enrichers(enrichers)
        send :define_method, :enrichers do
          enrichers
        end
      end

      def enricher_thread_count(thread_count)
        return unless thread_count.is_a? Numeric

        send :define_method, :thread_count do
          thread_count
        end
      end
    end

    module InstanceMethods
      def enrich_result(result)
        return unless defined?(enrichers)

        threads = defined?(thread_count) ? thread_count : DEFAULT_THREAD_COUNT
        result.entries.peach(threads) do |entry|
          enrichers.each do |enricher|
            enricher.enrich_entry entry
          end
        end
      end
    end
  end
end
