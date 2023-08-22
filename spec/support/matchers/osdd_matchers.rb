# frozen_string_literal: true

require 'nokogiri'
require File.join(File.dirname(__FILE__), 'matcher_helpers')

RSpec::Matchers.define :have_opensearch_root_element do
  match do |actual|
    xml = get_xml actual
    xml.xpath('/xmlns:OpenSearchDescription').length == 1
  end

  failure_message do |actual|
    "expected that #{truncate_string actual} would have a valid OpenSearch root element"
  end

  failure_message_when_negated do |actual|
    "expected that #{truncate_string actual} would not have a valid OpenSearch root element"
  end

  description do
    'have a valid OpenSearch root element'
  end
end

RSpec::Matchers.define :have_opensearch_namespace do
  match do |actual|
    xml = get_xml actual
    xml.namespaces.key?('xmlns') && xml.namespaces['xmlns'] == 'http://a9.com/-/spec/opensearch/1.1/'
  end

  failure_message do |actual|
    "expected that #{truncate_string actual} would have the OpenSearch namespace"
  end

  failure_message_when_negated do |actual|
    "expected that #{truncate_string actual} would not have the OpenSearch namespace"
  end

  description do
    'have the OpenSearch namespace'
  end
end

RSpec::Matchers.define :have_namespace do |prefix, url|
  match do |actual|
    xml = get_xml actual
    ns = "xmlns:#{prefix}"
    xml.namespaces.key?(ns) && xml.namespaces[ns] == url
  end
end

RSpec::Matchers.define :have_a_short_name do
  match do |actual|
    shortname_xpath = '/xmlns:OpenSearchDescription/xmlns:ShortName'
    xml = get_xml actual
    xml.xpath(shortname_xpath).length == 1 && xml.xpath(shortname_xpath).text.length >= 1
  end
end

RSpec::Matchers.define :have_a_description do
  match do |actual|
    description_xpath = '/xmlns:OpenSearchDescription/xmlns:Description'
    xml = get_xml actual
    xml.xpath(description_xpath).length == 1 && xml.xpath(description_xpath).text.length >= 1
  end
end

RSpec::Matchers.define :have_a_contact do
  match do |actual|
    xml = get_xml actual
    xml.xpath('/xmlns:OpenSearchDescription/xmlns:Contact').length == 1
  end
end

RSpec::Matchers.define :have_at_least_three_urls do
  match do |actual|
    xml = get_xml actual
    xml.xpath('/xmlns:OpenSearchDescription/xmlns:Url').length >= 3
  end
end

RSpec::Matchers.define :have_at_least_one_query do
  match do |actual|
    xml = get_xml actual
    xml.xpath('/xmlns:OpenSearchDescription/xmlns:Query').length >= 1
  end
end

RSpec::Matchers.define :have_at_least_one_image do
  match do |actual|
    xml = get_xml actual
    xml.xpath('/xmlns:OpenSearchDescription/xmlns:Image').length >= 1
  end
end

RSpec::Matchers.define :have_at_least_one_language do
  match do |actual|
    xml = get_xml actual
    xml.xpath('/xmlns:OpenSearchDescription/xmlns:Language').length >= 1
  end
end

RSpec::Matchers.define :have_at_least_one_input_encoding do
  match do |actual|
    xml = get_xml actual
    xml.xpath('/xmlns:OpenSearchDescription/xmlns:InputEncoding').length >= 1
  end
end

RSpec::Matchers.define :have_at_least_one_output_encoding do
  match do |actual|
    xml = get_xml actual
    xml.xpath('/xmlns:OpenSearchDescription/xmlns:OutputEncoding').length >= 1
  end
end

RSpec::Matchers.define :have_a_type do
  match do |actual|
    xml = get_xml actual
    !xml.root.attribute('type').nil?
  end
end

RSpec::Matchers.define :have_a_complete_template do |base, params|
  match do |actual|
    xml = get_xml actual
    t = xml.root.attribute('template')

    if t.nil?
      false
    elsif base.nil? || params.nil?
      true
    else
      text = t.text
      base_found = text.include? base
      params_found = true
      params.each do |k, v|
        params_found = false unless text.include? "#{k}={#{v}}"
      end

      base_found && params_found
    end
  end
end

RSpec::Matchers.define :have_an_image_url do
  match do |actual|
    xml = get_xml actual
    !xml.root.text.nil?
  end
end

RSpec::Matchers.define :have_a_role do
  match do |actual|
    xml = get_xml actual
    !xml.root.attribute('role').nil?
  end
end

RSpec::Matchers.define :have_parameters do |params|
  match do |actual|
    xml = get_xml actual

    if params.nil?
      true
    else
      params_found = true

      params.each do |k, v|
        params_found = false unless xml.root.attribute(k).text.eql? v
      end

      params_found
    end
  end
end
