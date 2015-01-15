require 'rest_client'
require 'nokogiri'

class OpenSearchDescriptionPage
  def initialize(url)
    @osdd_response = RestClient.get(url, 'X-Requested-With' => 'AceptanceTest')
    @doc = Nokogiri::XML @osdd_response.body
    @search_url_index = 1
  end

  def response_code
    @osdd_response.code
  end

  def url_template_value
    @doc.at_xpath('//xmlns:Url').attributes['template'].value
  end

  def url_template_hostname
    url_template_value.match('http://([^/]*)/')[@search_url_index]
  end

  def url_template_parameters
    parameter_str = url_template_value.match('[^?]*\?(.*)')[@search_url_index]
    parameter_parts = parameter_str.split('&')
    parameter_parts.map { |p| p.match('.*={([^?]*)\?*}')[@search_url_index] }
  end

  def blank_parameters
    parameters = {}
    url_template_parameters.each do |param|
      parameters[param] = ''
    end
    parameters
  end

  def example_query_parameters
    example_query = @doc.at_xpath('//xmlns:Query[@role="example"]')
    params = {}
    # ignore all namespaced parameters and just fill in search terms and index
    example_query.attributes.select { |akey| !akey.eql?('role') }.each do |akey, aval|
      if aval.namespace.nil?
        params[aval.name] = aval.value
      else
        params["#{aval.namespace.prefix}:#{aval.name}"] = ''
      end
    end
    params
  end
end
