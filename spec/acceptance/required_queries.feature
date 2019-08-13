Feature: Must-not-break search scenarios

  Background:
    Given there are the following valid environments:
      | Environment | Hostname              | Path                                |
      | development | localhost:3000        | OpenSearchDescription               |
      | integration | integration.nsidc.org | api/dataset/2/OpenSearchDescription |
      | qa          | qa.nsidc.org          | api/dataset/2/OpenSearchDescription |
      | staging     | staging.nsidc.org     | api/dataset/2/OpenSearchDescription |
      | production  | nsidc.org             | api/dataset/2/OpenSearchDescription |
    And I request the open search description document

  Scenario: glacier
    When I perform a text search for "glacier"
    Then The entries contain g01130 in the top 15
    And The entries contain nsidc-0272 in the top 15

  Scenario: snow cover
    When I perform a text search for "snow cover"
    Then The entries contain nsidc-0046 in the top 20
    And The entries contain mod10a2 in the top 20
    And The entries contain g02158 in the top 20
    And The entries contain g02156 in the top 20

  Scenario: Sea ice concentration
    When I perform a text search for "sea ice concentration"
    Then The entries contain NSIDC-0051 in the top 15
    And The entries contain NSIDC-0192 in the top 15
    And The entries contain NSIDC-0081 in the top 15
    And The entries contain NSIDC-0079 in the top 15

  Scenario: Sea ice extent
    When I perform a text search for "sea ice extent"
    Then The entries contain g02186 in the top 15
    And The entries contain g02135 in the top 15

  Scenario: modis
    When I perform a text search for "modis"
    Then The entries don't contain g02186 in the top 5

  Scenario: snow cover; Spatial bounding box "N:-40.0, S:-90.0, E:180.0, W:-180.0"
    When I perform a text search for "snow cover"
    And  I set the spatial bounding box to "N:-40.0, S:-90.0, E:180.0, W:-180.0"
    Then The entries don't contain nsidc-0046

  Scenario: snow cover; Temporal Coverage 1995-01-01 to 1999-12-31
    When I perform a text search for "snow cover"
    And I make a request with date range 1995-01-01 to 1999-12-31
    Then The entries don't contain mod10_l2

  Scenario: Joughin
    When I perform a text search for "Joughin"
    Then The entries contain nsidc-0523
    And The entries contain nsidc-0478
    And The entries contain nsidc-0481

  Scenario: LVIS
    When I perform a text search for "lvis"
    Then The entries contain ipplv1b
    And The entries contain ilvis2
    And The entries contain blvis2
    And The entries contain ilvis0
    And The entries contain blvis0
    And The entries contain ilvis1b
