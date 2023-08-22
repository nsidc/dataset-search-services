# frozen_string_literal: true

require 'tilt'
require File.join(File.dirname(__FILE__), '..', 'utils', 'class_extensions')
require File.join(File.dirname(__FILE__), 'osdd_base')
require File.join(File.dirname(__FILE__), 'url')
require File.join(File.dirname(__FILE__), 'image')
require File.join(File.dirname(__FILE__), 'query')

module OpenSearchDsl
  class OpenSearchDescriptionDocument
    include OsddBase

    dsl_methods :short_name, :description, :contact, :tags, :long_name, :developer, :attribution,
                :adult_content, :syndication_right
    attr_reader :urls, :queries, :images, :namespaces, :languages, :input_encodings,
                :output_encodings

    def initialize(&block)
      @builder_name = 'osdd'
      @urls = []
      @queries = []
      @images = []
      @namespaces = {}
      @languages = []
      @input_encodings = []
      @output_encodings = []
      @adult_content = 'false'
      @syndication_right = 'open'

      instance_eval(&block) if block

      raise ArgumentError, 'Missing short name' if @short_name.nil?
      raise ArgumentError, 'Missing description' if @description.nil?
      raise ArgumentError, 'Missing url' if @urls.empty?
    end

    def url(&block)
      @urls << Url.new(&block)
    end

    def query(*args, &block)
      @queries << Query.new(*args, &block)
    end

    def image(*args)
      @images << Image.new(*args)
    end

    def namespace(prefix, url)
      @namespaces[prefix] = url
    end

    def language(val)
      @languages << val
    end

    def input_encoding(val)
      @input_encodings << val
    end

    def output_encoding(val)
      @output_encodings << val
    end
  end
end
