Feature: Open Search Definition Basics

  Background:
    Given a valid environment
    And I request the open search description document

  @osdd_response
  Scenario: Successful response
    Then I should get 200 response code

  @osdd_hostname
  Scenario: Contains correct template hostname
    Then it should have a template with this environments hostname

  @osdd_template
  Scenario: Template has expected values
    Then the values should contain:
      | Value              |
      | searchTerms        |
      | nsidc:facetFilters |
      | startIndex         |
      | count              |
      | nsidc:source       |
      | geo:box            |
      | time:start         |
      | time:end           |
      | sortKeys           |

  @osdd_blank_options
  Scenario: Template url works with blanks
    When I make a request to the template url with blanks for optional parameters
    Then I get a valid response with entries

  @osdd_example_options
  Scenario: Template url works with the example values
    When I make a request to the template url with using the example query values
    Then I get a valid response with entries
