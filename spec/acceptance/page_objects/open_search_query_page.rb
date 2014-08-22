require 'rest_client'
require 'nokogiri'

class OpenSearchQueryPage
  def initialize(url)
    @url = url
  end

  def query(parameters)
    query_url = @url.dup
    parameters.each do |pkey, pvalue|
      query_url.sub!("{#{pkey}?}", CGI.escape(pvalue))
    end
    puts "Querying: #{query_url} ..."
    @response = RestClient.get(query_url, 'X-Requested-With' => 'AceptanceTest')
    @response_doc = Nokogiri::XML @response.body
  end

  def valid?
    @response.code.eql?(200)
  end

  def total_results
    @response_doc.at_xpath('//os:totalResults').text.to_i
  end

  def result_entries
    @response_doc.xpath('//xmlns:entry')
  end

  def result_entries_authoritative_ids
    auth_ids = []
    @response_doc.xpath('//xmlns:entry/nsidc:datasetId').each do |auth_field|
      auth_ids << auth_field.text
    end
    auth_ids
  end
end
