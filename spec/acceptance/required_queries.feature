Feature: Must-not-break search scenarios

  Background:
    Given a valid environment
    And I request the open search description document

  @search_spatial
  Scenario: Spatial query crossing date time line
    When I make a request with a date time line crossing bounding box
    Then I get a valid response with entries
    And The entries contain GGD904
    And The entries contain AE_L2A

  @search_temporal_multiple
  Scenario: Temporal query with a single day range
    When I make a request with date range "2003-07-02" to "2003-07-02"
    Then I get a valid response with entries
    And The entries don't contain NSIDC-0478
    And The entries contain NSIDC-0433
    And The entries contain NSIDC-0032

  @search_temporal_single
  Scenario: Temporal query with a single year range
    When I make a request with date range "1991-01-01" to "1992-01-01"
    Then I get a valid response with entries
    And The entries don't contain GGD648
    And The entries contain GGD601

  @search_glacier
  Scenario: Text search for glacier
    When I perform a text search for "glacier"
    Then The entries contain g01130 in the top 15
    And The entries contain nsidc-0272 in the top 15

  @search_snow_cover
  Scenario: Text search for snow cover
    When I perform a text search for "snow cover"
    Then The entries contain nsidc-0046 in the top 20
    And The entries contain mod10a2 in the top 20
    And The entries contain g02158 in the top 20
    And The entries contain g02156 in the top 20

  @search_sea_ice_concentration
  Scenario: Text search for sea ice concentration
    When I perform a text search for "sea ice concentration"
    Then The entries contain NSIDC-0051 in the top 15
    And The entries contain NSIDC-0192 in the top 15
    And The entries contain NSIDC-0081 in the top 15
    And The entries contain NSIDC-0079 in the top 15

  @search_sea_ice_extent
  Scenario: Text search for sea ice extent
    When I perform a text search for "sea ice extent"
    Then The entries contain g02186 in the top 15
    And The entries contain g02135 in the top 15

  @search_modis
  Scenario: Text search for modis
    When I perform a text search for "modis"
    Then The entries don't contain g02186 in the top 5

  @search_snow_cover_spatial
  Scenario: Text search for snow cover with a spatial bounding box
    When I perform a text search for "snow cover"
    And  I set the spatial bounding box to "N:-40.0, S:-90.0, E:180.0, W:-180.0"
    Then The entries don't contain nsidc-0046

  @search_snow_cover_temporal
  Scenario: Text search for snow cover with temporal Coverage
    When I perform a text search for "snow cover"
    And I make a request with date range 1995-01-01 to 1999-12-31
    Then The entries don't contain mod10_l2

  @search_investigator_joughin
  Scenario: Text search for Joughin
    When I perform a text search for "Joughin"
    Then The entries contain nsidc-0523
    And The entries contain nsidc-0478
    And The entries contain nsidc-0481

  @search_investigator_paden
  Scenario: Text search for paden
    When I perform a text search for "paden"
    Then I get a valid response with 11 entries
    And The entries contain IRKUB1B
    And The entries contain IRMCR1B
    And The entries contain BRMCR1B

  @search_lvis
  Scenario: Text search for LVIS
    When I perform a text search for "lvis"
    Then The entries contain ipplv1b
    And The entries contain ilvis2
    And The entries contain blvis2
    And The entries contain ilvis0
    And The entries contain blvis0
    And The entries contain ilvis1b
