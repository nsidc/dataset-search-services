# frozen_string_literal: true

def get_xml(actual)
  actual.respond_to?(:xpath) ? actual : Nokogiri::XML(actual) { |config| config.strict.nonet }
end

# Show first n chars of xml.  Add elipsis if truncation occurs.
def truncate_string(str, num = 10)
  if str.length <= num
    str
  else
    "#{str[0..num]}..."
  end
end
