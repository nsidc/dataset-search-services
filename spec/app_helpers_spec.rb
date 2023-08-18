# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'spec_helper')
require_relative '../lib/nsidc_open_search/helpers/app_helpers'

class AppHelperTestClass
  include NsidcOpenSearch::AppHelpers
  attr_accessor :request
  attr_accessor :settings
end

describe NsidcOpenSearch::AppHelpers do
  # rubocop:disable RSpec/VerifiedDoubles
  let(:app_helper) { AppHelperTestClass.new }
  let(:settings_stub) { double('settings') }
  let(:request_stub) { double('request') }
  # rubocop:enable RSpec/VerifiedDoubles

  before do
    allow(settings_stub).to receive(:relative_url_root).and_return('/api')
    app_helper.settings = settings_stub
    app_helper.request = request_stub
  end

  it 'produces a base_url' do
    allow(request_stub).to receive_messages(base_url: 'http://integration.nsidc.org',
                                            referrer: nil)

    expect(app_helper.base_url).to eql 'http://integration.nsidc.org/api'
  end

  it 'produces a http base_url with http referrer' do
    allow(request_stub).to receive_messages(base_url: 'http://nsidc.org', referrer: 'http://nsidc.org/api/dataset')

    expect(app_helper.base_url).to eql 'http://nsidc.org/api'
  end

  it 'produces a https base_url with https referrer' do
    allow(request_stub).to receive_messages(base_url: 'http://nsidc.org', referrer: 'https://nsidc.org/api/dataset')

    expect(app_helper.base_url).to eql 'https://nsidc.org/api'
  end
end
