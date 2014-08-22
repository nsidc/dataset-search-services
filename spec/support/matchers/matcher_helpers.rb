def get_xml(actual)
  actual.respond_to?(:xpath) ? actual : Nokogiri::XML(actual) { |config| config.strict.nonet }
end

# Show first n chars of xml.  Add elipsis if truncation occurs.
def truncate_string(str, n = 10)
  if str.length <= n
    str
  else
    str[0..n] + '...'
  end
end
