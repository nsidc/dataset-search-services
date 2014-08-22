require File.join(File.dirname(__FILE__), 'osdd_base')

module OpenSearchDsl
  class OpenSearchDescriptionDocument
    class Query
      include OsddBase

      dsl_methods :role
      attr_reader :parameters

      def initialize(role = 'example', &block)
        fail ArgumentError.new('Missing role') if role.nil_or_whitespace?

        @parameters = {}
        @role = role

        instance_eval(&block) if block
      end

      def parameter(name, val)
        @parameters[name] = val
      end
    end
  end
end
