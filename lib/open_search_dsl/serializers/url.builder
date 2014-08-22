attrs = {
    'type' => type
}

namespaces.each do |k, v|
  attrs["xmlns:#{k}"] = v
end

template = template_parameters.count > 1 ? "#{base_url}?#{template_parameters.map { |t| "#{t.name}={#{t.replace_val}#{!t.required ? '?' : ''}}" }.join('&')}" : "#{base_url}"

attrs['template'] = template

xml.Url attrs