attrs = {}

attrs['height'] = height unless height.nil?
attrs['width'] = width unless width.nil?
attrs['type'] = type unless type.nil?

xml.Image attrs, url
