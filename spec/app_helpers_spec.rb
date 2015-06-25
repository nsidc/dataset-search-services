require File.join(File.dirname(__FILE__), 'spec_helper')
require_relative '../lib/nsidc_open_search/helpers/app_helpers'

describe 'Nsidc OpenSearch App Helper' do
  class AppHelperTestClass
    include NsidcOpenSearch::AppHelpers
    attr_accessor :request
    attr_accessor :settings
  end

  before(:each) do
    @app_helper = AppHelperTestClass.new
    settings_stub = double('settings')
    allow(settings_stub).to receive(:relative_url_root).and_return('/api')
    @request_stub = double('request')
    @app_helper.settings = settings_stub
    @app_helper.request = @request_stub
  end

  it 'produces a base_url' do
    allow(@request_stub).to receive(:base_url).and_return('http://integration.nsidc.org')
    allow(@request_stub).to receive(:referrer).and_return(nil)

    expect(@app_helper.base_url).to eql 'http://integration.nsidc.org/api'
  end

  it 'produces a http base_url with http referrer' do
    allow(@request_stub).to receive(:base_url).and_return('http://nsidc.org')
    allow(@request_stub).to receive(:referrer).and_return('http://nsidc.org/api/dataset')

    expect(@app_helper.base_url).to eql 'http://nsidc.org/api'
  end

  it 'produces a https base_url with https referrer' do
    allow(@request_stub).to receive(:base_url).and_return('http://nsidc.org')
    allow(@request_stub).to receive(:referrer).and_return('https://nsidc.org/api/dataset')

    expect(@app_helper.base_url).to eql 'https://nsidc.org/api'
  end
end
