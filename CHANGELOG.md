## v5.2.0 (2023-10-31)

  - Refine facet `short_name_sort` to compare strings case-insensitively.

## v5.1.0 (2023-10-11)

  - Splitting `Featured` facet into `Storage Location` and 
    `Spatial Coverage` facets

## v5.0.0 (2023-10-09)

  - Adding `Featured` facet, removing `Spatial Coverage` Facet

## v4.0.2 (2023-10-04)

  - Documentation updates.

## v4.0.1 (2023-08-28)

  - Minor fix to the bump CI job script.

## v4.0.0 (2023-08-28)

  - Update Ruby version to 3.2.2, as well as gem dependencies
  - Significant refactoring for compliance with Rubocop standards
  - VM configuration updates to use Puppet 7
  - CI machine configuration to use latest Jenkins module

## v3.7.0 (2023-07-12)

  - CI updates to reflect the change from `master` to `main` as the default
    branch. Note that these changes have *not* been tested by building a new CI
    machine. Additional VM configuration updates will be handled in a separate
    story.

## v3.6.0 (2020-07-01)

  - Update Ruby version to 2.6.5, as well as various gem dependencies

## v3.5.1 (2019-10-17)

  - Update RubyGem per security announcement

## v3.5.0 (2019-08-26)  
  
  - Add nginx server and reverse proxy to allow for HTTPS

## v3.4.0 (2019-08-26)

  - Update `bundler` to 2.0.1
  - Update Nokogiri version (security update).
  - Add acceptance test documentation to DEVELOPMENT.md.
  - Add custom formatter for RSpec to support Ops monitoring of acceptance test
    jobs and enable an option to list all tags associated with acceptance test
    scenarios.
  - Remove duplicate bootstrapping information from acceptance test feature set-up.

## v3.3.0 (2019-08-19)

Changes:

  - Removed ISO Topic from the list of fields queried for search terms
  - No longer boosting Authoritative ID matches
  - No longer boosting keyword matches

## v3.2.0 (2019-07-12)

Changes:

  - Switched from environment-specific Solr query configuration files to one
    common configuration file. The exception is the configuration for the test
    environment, which still has its own configuration.
  - Added YARD gems to support a `rake routes` task.
  - Minor documentation reformatting.

## v3.1.0 (2019-06-07)

Changes:

  - Updated vagrant configuration
  - Changed documentation to explain systemd setup
  - Update Ruby, Rubocop, and Nokogiri versions to address security warnings.

## v3.0.2 (2017-07-25)

Bugfixes:

  - Add X-Requested-With response header, which allows cross-origin requests
    from browsers that send a preflight request first.

## v3.0.1 (2017-03-28)

Bugfixes:

  - Update name for ACADIS data center to NSF Arctic Data Center.

## v3.0.0 (2016-05-19)

Changes:

  - Update builders to remove enricher needs
  - Remove ISO enricher, use solr for all needed info instead

## v2.0.3 (2016-01-19)

Changes:

  - Removed Libre Metrics connections and references

## v2.0.2 (2015-09-25)

Bugfixes:

  - Re-enabled enricher calls for NSIDC results; removing them broke data access
    links and supporting program information; the call was not actually related
    to GI-Cat

## v2.0.1 (2015-09-23)

Bugfixes:

  - Removed ISO enricher/calls to GI-CAT
  - Stopped saving/adding acceptance test reports
  - Fixed rake task bug where puma would not restart on deployment

## v2.0.0 (2015-06-29)

Changes:

  - Upgraded from Ruby 1.9.3 to 2.2.2

## v1.0.3 (2015-05-08)

Bugfixes:

  - Fix problem with X-Forwaded-For header processing
    which ultimately caused failures to send to Libre
    metrics

## v1.0.2 (2015-02-11)

Bugfixes:

  - Point solr_url at the new solr, minor config updates

## v1.0.1 (2015-02-02)

Features:

  - Configured project to work with vagrant-nsidc plugin

## v1.0.0 (2014-08-21)

Features:

  - Please see the Production Change Tracker board on NSIDC's internal JIRA
    instance for change history up to and including v1.0.0.
