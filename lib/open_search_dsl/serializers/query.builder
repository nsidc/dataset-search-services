attrs = {
    'role' => role
}

parameters.each do |k, v|
  attrs[k] = v
end

xml.Query attrs