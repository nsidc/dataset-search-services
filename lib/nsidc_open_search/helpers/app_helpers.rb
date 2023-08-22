# frozen_string_literal: true

require 'sinatra/base'

module NsidcOpenSearch
  module AppHelpers
    def base_url
      url = "#{request.base_url}#{settings.relative_url_root}".chomp('/')
      url.sub!('http:', 'https:') if !request.referrer.nil? && request.referrer.start_with?('https')
      url
    end
  end
end
