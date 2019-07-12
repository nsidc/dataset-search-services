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
