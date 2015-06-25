require File.join(File.dirname(__FILE__), '..', 'utils', 'dsl_base')

module OpenSearchDsl
  module OsddBase
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend(DslBase)
    end

    module InstanceMethods
      def to_xml
        @builder_name ||= self.class.name.split('::').last.downcase
        Tilt.new(File.dirname(__FILE__) + "/serializers/#{@builder_name}.builder").render(self)
      end
    end
  end
end
