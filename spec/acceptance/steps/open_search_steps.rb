require 'acceptance/page_objects/open_search_description_page'
require 'acceptance/page_objects/open_search_query_page'

module OpenSearchSteps
  attr_reader :osdd

  # Given steps
  step 'there are the following valid environments:' do |envTable|
    @target_env = ENV['TARGET_ENVIRONMENT'] || 'development'
    @valid_envs = {}
    envTable.hashes.each do |hash|
      @valid_envs[hash['Environment']] = hash
    end
  end

  step 'I request the open search description document' do
    osdd_url = "http://#{@valid_envs[@target_env]['Hostname']}/#{@valid_envs[@target_env]['Path']}"
    puts "OSDD_URL: #{osdd_url}"
    @osdd = OpenSearchDescriptionPage.new(osdd_url)
  end

  # When steps
  step 'I make a request to the template url with blanks for optional parameters' do
    @parameters = osdd.blank_parameters
  end

  step 'I make a request to the template url with using the example query values' do
    @parameters = osdd.example_query_parameters
  end

  step 'I make a request with a date time line crossing bounding box' do
    parameters['geo:box'] = '160.0,55.0,-160.0,80.0'
    parameters['count'] = '500'
  end

  step 'I make a request with date range :start_date to :end_date' do |start_date, end_date|
    parameters['time:start'] = start_date
    parameters['time:end'] = end_date
    parameters['count'] = '200'
  end

  step 'I make a request with investigator :data_contributor' do |data_contributor|
    parameters['searchTerms'] = data_contributor
  end

  # Then steps
  step 'I should get :code response code' do |code|
    osdd.response_code.should be code.to_i
  end

  step 'it should have a template with this environments hostname' do
    osdd.url_template_hostname.should eql @valid_envs[@target_env]['Hostname']
  end

  step 'the values should contain:' do |values|
    expected_values = []
    values.hashes.each do |vhash|
      expected_values.push(vhash['Value'])
    end
    osdd.url_template_parameters.should =~ expected_values
  end

  step 'I get a valid response with entries' do
    page.valid?.should be true
    page.total_results.should be > 10
    page.result_entries.size.should be > 10
  end

  step 'I get a valid response with :count entries' do |count|
    page.valid?.should be true
    page.total_results.should be count.to_i
    page.result_entries.size.should be count.to_i
  end

  step 'The entries contain :auth_id' do |auth_id|
    result_entries_authoritative_ids.should include auth_id.upcase
  end

  step 'The entries don\'t contain :auth_id' do |auth_id|
    result_entries_authoritative_ids.should_not include auth_id.upcase
  end

  private

  def page
    if @page.nil?
      @page = OpenSearchQueryPage.new(osdd.url_template_value)
      @page.query(parameters)
    end

    @page
  end

  def parameters
    @parameters ||= osdd.blank_parameters
    @parameters
  end

  def result_entries_authoritative_ids
    @results = page.result_entries_authoritative_ids if @results.nil?
    @results
  end
end

RSpec.configure { |c| c.include OpenSearchSteps }
