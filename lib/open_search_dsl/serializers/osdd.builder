require_relative '../../utils/class_extensions'

xml.instruct!
xml_namespaces = {
  'xmlns' => 'http://a9.com/-/spec/opensearch/1.1/'
}

namespaces.each do |k, v|
  xml_namespaces["xmlns:#{k}"] = v
end

xml.OpenSearchDescription xml_namespaces do
  xml.ShortName(short_name)
  xml.Description(description)

  urls.each do |u|
    xml << u.to_xml
  end

  queries.each do |q|
    xml << q.to_xml
  end

  images.each do |i|
    xml << i.to_xml
  end

  %i(Contact Tags LongName Developer Attribution SyndicationRight AdultContent).each do |tag|
    val = send(tag.to_s.to_underscore.to_sym)
    xml.tag! tag, val unless val.nil?
  end

  languages.each do |l|
    xml.Language l
  end

  input_encodings.each do |i|
    xml.InputEncoding i
  end

  output_encodings.each do |o|
    xml.OutputEncoding o
  end
end
