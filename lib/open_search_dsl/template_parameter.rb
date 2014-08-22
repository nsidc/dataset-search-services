require File.join(File.dirname(__FILE__), '..', 'utils', 'dsl_base')

module OpenSearchDsl
  class OpenSearchDescriptionDocument
    class Url
      class TemplateParameter
        extend DslBase

        dsl_methods :name, :replace_val, :required

        def initialize(name, replace_val, required = false)
          fail ArgumentError.new('Missing name') if name.nil_or_whitespace?
          fail ArgumentError.new('Missing replacement value') if replace_val.nil_or_whitespace?

          @name, @replace_val, @required =  name, replace_val, required
        end
      end
    end
  end
end
