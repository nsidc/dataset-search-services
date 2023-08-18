# frozen_string_literal: true

require 'acceptance/page_objects/open_search_description_page'
require 'acceptance/page_objects/open_search_query_page'
require './config/app_config'

module OpenSearchSteps
  attr_reader :osdd

  # Given steps
  # Use the TARGET_ENVIRONMENT environment variable, and the "relative_url_root"
  # value in app_config.yaml, to construct the OSDD URL.
  step 'a valid environment' do
    @target_env = ENV['TARGET_ENVIRONMENT'] || 'development'
    config = AppConfig[@target_env]
    @host = full_hostname(@target_env)
    @path = [config[:relative_url_root], 'OpenSearchDescription'].join('/')
  end

  step 'I request the open search description document' do
    osdd_url = "http://#{@host}#{@path}"
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

  # Then steps
  step 'I should get :code response code' do |code|
    expect(osdd.response_code).to be(code.to_i)
  end

  step 'it should have a template with this environments hostname' do
    expect(osdd.url_template_hostname).to eq(@host)
  end

  step 'the values should contain:' do |values|
    expected_values = []
    values.hashes.each do |vhash|
      expected_values.push(vhash['Value'])
    end
    expect(osdd.url_template_parameters).to match_array(expected_values)
  end

  step 'I get a valid response with entries' do
    expect(page.valid?).to be(true)
    expect(page.total_results).to be > 10
    expect(page.result_entries.size).to be > 10
  end

  step 'I get a valid response with :count entries' do |count|
    expect(page.valid?).to be true
    expect(page.total_results).to be(count.to_i)
    expect(page.result_entries.size).to be(count.to_i)
  end

  step 'The entries contain :auth_id' do |auth_id|
    expect(result_entries_authoritative_ids).to include(auth_id.upcase)
  end

  step 'The entries don\'t contain :auth_id' do |auth_id|
    expect(result_entries_authoritative_ids).not_to include(auth_id.upcase)
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

  # Generate a full hostname for the target environment
  def full_hostname(env)
    domain = 'nsidc.org'
    case env
    when 'development'
      'localhost:3000'
    when 'production'
      domain
    else
      [env, domain].join('.')
    end
  end
end

RSpec.configure { |c| c.include OpenSearchSteps }
