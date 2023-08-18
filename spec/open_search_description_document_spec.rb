# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/open_search_dsl/open_search_description_document'

describe OpenSearchDsl::OpenSearchDescriptionDocument do
  describe OpenSearchDsl::OpenSearchDescriptionDocument::Url::TemplateParameter do
    it 'cannont be created without name and replace val' do
      expect do
        described_class.new '', ''
      end.to raise_error(ArgumentError)
    end
  end

  describe OpenSearchDsl::OpenSearchDescriptionDocument::Url do
    it 'cannot be constructed without type, base url, and parameters' do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new { type 'atom' } }.to raise_error(ArgumentError)
      expect { described_class.new { base_url 'url' } }.to raise_error(ArgumentError)
      expect { described_class.new { parameter 'name', 'val' } }.to raise_error(ArgumentError)
    end

    it 'outputs a valid OSDD Url element' do
      parameters = {
        'st' => 'searchTerm',
        'bbox' => 'bbox?'
      }
      url = described_class.new do
        type 'atom'
        base_url 'http://test.org/dataset'
        parameters.each do |k, v|
          optional = v.end_with? '?'
          parameter k, (optional ? v.chop : v), !optional
        end
      end

      xml = url.to_xml

      expect(xml).to have_a_type
      expect(xml).to have_a_complete_template url.base_url, parameters
    end

    it 'preserves the https protocol' do
      url = described_class.new do
        type 'atom'
        base_url 'https://test.org/dataset'
        parameter 'st', 'searchTerm', true
      end

      xml = url.to_xml
      template = get_xml(xml).root.attribute('template')

      expect(template.value).to eql 'https://test.org/dataset'
      have_a_complete_template url.base_url, 'st' => 'searchTerm'
    end
  end

  describe OpenSearchDsl::OpenSearchDescriptionDocument::Image do
    it 'cannot be constructed without url' do
      expect do
        described_class.new ''
      end.to raise_error(ArgumentError)
    end

    it 'outputs a valid OSDD Image element' do
      img = described_class.new 'http://test.org/image.jpg'
      xml = img.to_xml
      expect(xml).to have_an_image_url
    end
  end

  describe OpenSearchDsl::OpenSearchDescriptionDocument::Query do
    it 'cannot be constructed without role' do
      expect do
        described_class.new ''
      end.to raise_error(ArgumentError)
    end

    it 'allows multiple parameters' do
      q = described_class.new do
        parameter 'name', 'val'
        parameter 'name2', 'val2'
      end

      expect(q.parameters.length).to be 2
    end

    it 'outputs a valid OSDD Query element' do
      parameters = {
        'st' => 'searchTerm',
        'bbox' => 'bbox'
      }

      q = described_class.new do
        parameters.each do |k, v|
          parameter k, v
        end
      end

      xml = q.to_xml
      expect(xml).to have_a_role
      expect(xml).to have_parameters parameters
    end
  end

  describe OpenSearchDsl::OpenSearchDescriptionDocument do
    it 'cannot be constructed without short name, description and url' do
      url_block = lambda do
        type 'atom'
        base_url 'url'
        parameter 'name', 'val'
      end

      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new { short_name 'Short Name' } }.to raise_error(ArgumentError)
      expect { described_class.new { description 'Description' } }.to raise_error(ArgumentError)
      expect { described_class.new { url(&url_block) } }.to raise_error(ArgumentError)
    end

    it 'allows multiple languages' do
      osdd = described_class.new do
        short_name 'Short Name'
        description 'Description'
        url do
          type 'atom'
          base_url 'url'
          parameter 'name', 'val'
        end
        language 'en'
        language 'fr'
      end

      expect(osdd.languages.length).to be 2
    end

    it 'allows multiple input encodings' do
      osdd = described_class.new do
        short_name 'Short Name'
        description 'Description'
        url do
          type 'atom'
          base_url 'url'
          parameter 'name', 'val'
        end
        input_encoding 'utf-8'
        input_encoding 'utf-16'
      end

      expect(osdd.input_encodings.length).to be 2
    end

    it 'allows multiple output encodings' do
      osdd = described_class.new do
        short_name 'Short Name'
        description 'Description'
        url do
          type 'atom'
          base_url 'url'
          parameter 'name', 'val'
        end
        output_encoding 'utf-8'
        output_encoding 'utf-16'
      end

      expect(osdd.output_encodings.length).to be 2
    end

    it 'outputs a valid OSDD' do
      osdd = described_class.new do
        short_name 'Short Name'
        description 'Description'
        url do
          type 'atom'
          base_url 'url'
          parameter 'query', 'val'
        end
        url do
          type 'atom'
          base_url 'url'
          parameter 'facet', 'val'
        end
        url do
          type 'json'
          base_url 'url'
          parameter 'suggest', 'val'
        end
      end

      xml = osdd.to_xml

      expect(xml).to have_opensearch_namespace
      expect(xml).to have_opensearch_root_element
      expect(xml).to have_a_short_name
      expect(xml).to have_a_description
      expect(xml).to have_at_least_three_urls
    end

    it 'outputs a valid OSDD with optional elements' do
      osdd = described_class.new do
        namespace 'time', 'http://a9.com/-/opensearch/extensions/time/1.0/'
        short_name 'Short Name'
        description 'Description'
        url do
          type 'atom'
          base_url 'url'
          parameter 'name', 'val'
        end
        query { parameter 'st', 'searchTerm' }
        image 'http://test.org/image.jpg'
        long_name 'this is a test osdd'
        contact 'test@test.org'
        language 'en-us'
        input_encoding 'utf-8'
        output_encoding 'utf-8'
      end

      xml = osdd.to_xml

      expect(xml).to have_namespace 'time', 'http://a9.com/-/opensearch/extensions/time/1.0/'
      expect(xml).to have_a_contact
      expect(xml).to have_at_least_one_query
      expect(xml).to have_at_least_one_image
      expect(xml).to have_at_least_one_language
      expect(xml).to have_at_least_one_input_encoding
      expect(xml).to have_at_least_one_output_encoding
    end
  end
end
