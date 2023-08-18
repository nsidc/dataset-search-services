# frozen_string_literal: true

require 'acceptance/steps/open_search_steps'
require 'acceptance/page_objects/open_search_description_page'
require 'acceptance/page_objects/open_search_query_page'

module RequiredQueriesSteps
  include OpenSearchSteps

  step 'I perform a/an text search for :terms' do |terms|
    parameters['searchTerms'] = terms
  end

  step 'I set the spatial bounding box to :bbox' do |bbox|
    # input string has format N:<north>, S:<south>, E:<east>, W:<west>
    # convert to <west>,<south>,<east>,<north>

    corners = bbox.scan(/-?\d+(?:\.\d+)?/)

    parameters['geo:box'] = "#{corners[3]},#{corners[1]},#{corners[2]},#{corners[0]}"
  end

  step 'The entries contain :auth_id in the top :limit' do |auth_id, limit|
    expect(result_entries_authoritative_ids).to include(auth_id.upcase)
    expect(result_entries_authoritative_ids.index(auth_id.upcase)).to be < limit.to_i
  end

  step 'The entries don\'t contain :auth_id in the top :limit' do |auth_id, limit|
    expect(result_entries_authoritative_ids).to include(auth_id.upcase)
    expect(result_entries_authoritative_ids.index(auth_id.upcase)).to be >= limit.to_i
  end
end

RSpec.configure { |c| c.include RequiredQueriesSteps }
