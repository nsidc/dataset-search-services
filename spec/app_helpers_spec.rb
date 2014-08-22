require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'helpers', 'app_helpers')

describe 'Nsidc OpenSearch App Helper' do
  class AppHelperTestClass
    include NsidcOpenSearch::AppHelpers
    attr_accessor :request
    attr_accessor :settings
  end

  before(:each) do
    @app_helper = AppHelperTestClass.new
    settings = Class.new
    request = Class.new
    settings_stub = double('settings')
    settings_stub.stub(:relative_url_root).and_return('/api')
    @request_stub = double('request')
    @app_helper.settings = settings_stub
    @app_helper.request = @request_stub
  end

  it 'produces a base_url' do
    @request_stub.stub(:base_url).and_return('http://integration.nsidc.org')
    @request_stub.stub(:referrer).and_return(nil)

    @app_helper.base_url.should eql 'http://integration.nsidc.org/api'
  end

  it 'produces a http base_url with http referrer' do
    @request_stub.stub(:base_url).and_return('http://nsidc.org')
    @request_stub.stub(:referrer).and_return('http://nsidc.org/api/dataset')

    @app_helper.base_url.should eql 'http://nsidc.org/api'
  end

  it 'produces a https base_url with https referrer' do
    @request_stub.stub(:base_url).and_return('http://nsidc.org')
    @request_stub.stub(:referrer).and_return('https://nsidc.org/api/dataset')

    @app_helper.base_url.should eql 'https://nsidc.org/api'
  end
end
