# NSIDC Open Search

NOTE: this README is up to date with the master branch, meaning it may contain
information for an unreleased version of **dataset-search-services**. For details on what
may have changed since the version you are using, see the
[Changelog](https://bitbucket.org/nsidc/dataset-search-services/src/master/CHANGELOG.md).

Nsidc OpenSearch web service (yet another OpenSearch)

The service currently exposes four endpoints:

* `/OpenSearchDescription` - OpenSearch Description Document
* `/OpenSearch` - dataset search, used by NSIDC Search and the ADE
* `/Facets` - facets to go with the dataset search
* `/suggest` - retrieve suggested phrase completions for auto-suggest/auto-complete

## Developer Info

Instructions and notes for developing this project are in
[DEVELOPMENT](https://bitbucket.org/nsidc/dataset-search-services/src/master/DEVELOPMENT.md).


## How to contact NSIDC

User Services and general information:  
Support: http://support.nsidc.org  
Email: nsidc@nsidc.org  

Phone: +1 303.492.6199  
Fax: +1 303.492.2468  

Mailing address:  
National Snow and Ice Data Center  
CIRES, 449 UCB  
University of Colorado  
Boulder, CO 80309-0449 USA

## License

Every file in this repository is covered by the GNU GPL Version 3; a copy of the
license is included in the file COPYING.
