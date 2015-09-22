Feature: Open Search Definition Basics

  Background:
    Given there are the following valid environments:
      | Environment | Hostname              | Path                                |
      | development | localhost:3000        | OpenSearchDescription               |
      | integration | integration.nsidc.org | api/dataset/2/OpenSearchDescription |
      | qa          | qa.nsidc.org          | api/dataset/2/OpenSearchDescription |
      | staging     | staging.nsidc.org     | api/dataset/2/OpenSearchDescription |
      | production  | nsidc.org             | api/dataset/2/OpenSearchDescription |
    And I request the open search description document

  Scenario: Successful response
    Then I should get 200 response code

  Scenario: Contains correct template hostname
    Then it should have a template with this environments hostname

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

  Scenario: Template url works with blanks
    When I make a request to the template url with blanks for optional parameters
    Then I get a valid response with entries

  Scenario: Template url works with the example values
    When I make a request to the template url with using the example query values
    Then I get a valid response with entries

  Scenario: Spatial query crossing date time line returns point and box results from both sides of the date time line
    When I make a request with a date time line crossing bounding box
    Then I get a valid response with entries
    And The entries contain GGD904
    And The entries contain AE_L2A

  Scenario: Temporal query gets correct datasets with multiple date ranges and a single day temporal search
    When I make a request with date range "2003-07-02" to "2003-07-02"
    Then I get a valid response with entries
    And The entries don't contain NSIDC-0478
    And The entries contain NSIDC-0433
    And The entries contain NSIDC-0032

  Scenario: Temporal query gets correct datasets with a single year temporal search
    When I make a request with date range "1991-01-01" to "1992-01-01"
    Then I get a valid response with entries
    And The entries don't contain GGD648
    And The entries contain GGD601

  Scenario: Investigator query gets correct datasets for a data contributor of any type.
    When I make a request with investigator "paden"
    Then I get a valid response with 5 entries
    And The entries contain IRKUB1B
    And The entries contain IRMCR1B
    And The entries contain BRMCR1B
