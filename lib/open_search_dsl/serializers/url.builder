attrs = {
  'type' => type
}

namespaces.each do |k, v|
  attrs["xmlns:#{k}"] = v
end

template = base_url

if template_parameters.count > 1
  params = template_parameters.map do |param|
    value = param.replace_val
    value.concat('?') unless param.required

    "#{param.name}={#{value}}"
  end.join('&')

  template.concat("?#{params}")
end

attrs['template'] = template

xml.Url(attrs)
