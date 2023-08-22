# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'osdd_base')
require File.join(File.dirname(__FILE__), 'template_parameter')

module OpenSearchDsl
  class OpenSearchDescriptionDocument
    class Url
      include OsddBase

      dsl_methods :type, :base_url, :rel
      attr_reader :template_parameters, :namespaces

      def initialize(&block)
        @template_parameters = []
        @namespaces = {}

        instance_eval(&block) if block

        raise ArgumentError, 'Missing type' if @type.nil?
        raise ArgumentError, 'Missing base url' if @base_url.nil?
      end

      def parameter(*args)
        @template_parameters << TemplateParameter.new(*args)
      end

      def namesapce(prefix, url)
        @namespaces[prefix] = url
      end
    end
  end
end
