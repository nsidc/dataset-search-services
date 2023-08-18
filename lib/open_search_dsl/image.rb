# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'osdd_base')

module OpenSearchDsl
  class OpenSearchDescriptionDocument
    class Image
      include OsddBase

      dsl_methods :height, :width, :type, :url

      def initialize(url, height = nil, width = nil, type = nil)
        raise ArgumentError, 'Missing url' if url.nil_or_whitespace?

        @url = url
        @height = height
        @width = width
        @type = type
      end
    end
  end
end
