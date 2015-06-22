require File.join(File.dirname(__FILE__), '..', 'utils', 'dsl_base')

module OpenSearchDsl
  class OpenSearchDescriptionDocument
    class Url
      class TemplateParameter
        extend DslBase

        dsl_methods :name, :replace_val, :required

        def initialize(name, replace_val, required = false)
          fail ArgumentError, 'Missing name' if name.nil_or_whitespace?
          fail ArgumentError, 'Missing replacement value' if replace_val.nil_or_whitespace?

          @name = name
          @replace_val = replace_val
          @required = required
        end
      end
    end
  end
end
