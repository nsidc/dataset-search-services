# NSIDC Open Search

NOTE: this README is up to date with the master branch, meaning it may contain
information for an unreleased version of **dataset-search-services**. For details on what
may have changed since the version you are using, see the
[Changelog](https://bitbucket.org/nsidc/dataset-search-services/src/master/CHANGELOG.md). For
past versions of the README, see:

* [v1.0.0](https://bitbucket.org/nsidc/dataset-search-services/src/v1.0.0/?at=v1.0.0)
* [v1.0.1](https://bitbucket.org/nsidc/vagrant-nsidc-plugin/src/v1.0.1/?at=v1.0.1)

Nsidc OpenSearch web service (yet another OpenSearch)

The service currently exposes four endpoints:

* /OpenSearchDescription - OpenSearch Description Document
* /OpenSearch - dataset search, used by NSIDC Search and the ADE
* /Facets - facets to go with the dataset search
* /suggest - retrieve suggested phrase completions for auto-suggest/auto-complete

## Developer Info

Instructions and notes for developing this project are in
[DEVELOPMENT](https://bitbucket.org/nsidc/dataset-search-services/src/master/DEVELOPMENT.md).

## Design

At the core of the service is a search definition.
The definition includes a method for each of the search terms terms as well as a list of valid term combinations.
This list of valids is used to generate Query and Url examples in the OpenSearch description documents and to
verify parameters in search requests.

Complimenting the definition is a search implementation. Implementations must
provide an execute method which accepts a hash of valid search term. Execute methods
must return an open search response builder.

### Class-responsibility-collaboration
* Dataset::Search::Definition - definition of terms for a dataset search
* Dataset::Search::DefinitionSuggest - definition of terms for an auto-suggest search
* Dataset::Search::SolrSearch - implementation that executes a SOLR query and returns a set of matching datasets or facets using the parser and response builder passed to its instance.
    * RSolr
    * RSolr::Ext
    * Dataset::Model::Search::OpenSearchResponseBuilder / Dataset::Model::Facets::FacetsResponseBuilder
    * Dataset::Search::SolrResultsParser / Dataset::Search::SolrFacetsParser
* Dataset::Search::SolrSearch - implementation that executes a SOLR query and returns a set of matching auto-suggest completions using the parser and response builder passed to its instance.
    * RSolr
    * Dataset::Model::Suggestions::SuggestionResponseBuilder
    * Dataset::Search::SolrSuggestionsParser

* Dataset::Search::ResultsParameterFactory - generates a hash of search parameters based on parameters from the request and a list of valids
* Dataset::Search::FacetsParameterFactory - generates a hash of search parameters based on parameters from the request and a list of valids. Sets :facets to true and count to 0 since we just want the facets.
* Dataset::Search::SuggestionsParameterFactory - generates a hash of search parameters based on parameters from the request and a list of valids
* Dataset::Model::Search::OpenSearchResponseBuilder - results of a dataset search which can be serialized to ATOM
    * Dataset::Model::Search::ResultEntry
* Dataset::Model::Search::ResultEntry - a single dataset in the results
* Dataset::Model::Facets::FacetsResponseBuilder - results of a faceted search which can be serialized to ATOM
    * Dataset::Model::Facets::FacetEntry
* Dataset::Model::Facets::FacetEntry - a single facet in the results
* Dataset::Model::Suggestions::SuggestionsResponseBuilder - results of a suggestion search which can be serialized to JSON based on the [OpenSearch Extension](http://www.opensearch.org/Specifications/OpenSearch/Extensions/Suggestions/1.1)
    * Dataset::Model::Suggestions::SuggestionEntry
* Dataset::Model::Suggestions::SuggestionEntry - a single suggestion for the searched upon term. Contains just completion suggestion, but with the OpenSearch Suggestion standard can optionally contain a description (like number of results the full query with this completion would return) and the full URL to execute the search using the completion.
* DatasetSearch - specifies the definition, parameter factory, and implementation to use in a search query (parser and builder)
    * Dataset::Search::Definition
    * Dataset::Search::SolrSearch
    * Dataset::Search::ResultsParameterFactory
    * Dataset::Search::SolrResultsParser
    * Dataset::Model::Search::OpenSearchResponseBuilder
    * Search
* DatasetFacets - specifies the definition, parameter factory, and implementation to use in a faceted query (parser and builder)
    * Dataset::Search::Definition
    * Dataset::Search::SolrSearch
    * Dataset::Search::FacetsParameterFactory
    * Dataset::Search::SolrFacetsParser
    * Dataset::Model::Facets::FacetsResponseBuilder
    * Search
* DatasetSuggestions - specifies the definition, parameter factory, and implementation to use in a faceted query (parser and builder)
    * Dataset::Search::DefinitionSuggest
    * Dataset::Search::SolrSearchSuggest
    * Dataset::Search::SuggestParameterFactory
    * Dataset::Search::SolrSuggestionsParser
    * Dataset::Model::Suggestions::SuggestionsResponseBuilder
    * Search
* Search - implementation of the search algorithm: validate inputs, execute search, enrich results
    * Validator
    * SearchAdapter
    * Enricher
* Validtor - validate search inputs with a given search definition
* SearchAdapter - executes a search by calling the execute method of a given search implementation with the parameters from a given parameter factory
* Enricher - updates each result entry with a given set of entry enrichers
* App - the main application
    * Sinatra::Base
    * Controllers::DatasetOsdd
    * Controllers::DatasetSearch
    * Controllers::DatasetFacets
    * Controllers::DatasetSuggestions
* Routes - contains a list of named routes supported by the application
* DatasetOsdd - implements an OpenSearch description document for dataset searches
    * Dataset::Search::Definition
    * Routes
* Controllers::DatasetOsdd - handler for OpenSeachDescription requests
    * DatasetOsdd
    * Routes
    * Sinatra
* Controllers::DatasetSearch - handler for OpenSearch requests
    * DatasetSearch
    * Routes
    * Sinatra
* Controllers::DatasetFacets - handler for Faceted requests
    * DatasetFacets
    * Routes
    * Sinatra
* Controllers::DatasetSuggestions - handler for Suggestion requests
    * DatasetSuggestions
    * Routes
    * Sinatra


### A simple example

A sample search definition:

    class Definition
      def self.valids
        [[:keywords, :title]]
      end
    end


OpenSearchDescription URL based on the definition:

    <Url type="application/atom+xml" template="http://example.com/OpenSearch?keywords={keywords?}&title={title?}"/>


A search implementation of the definition:

    class SearchImpl
      def execute(parameters)
        #evaluate the parameters and run a search
      end
    end

Invoking a search:

    impl = SearchImpl.new
    impl.execute {
      :keywords => 'asdf'
      :title => 'jkl;'
    }

### How to add a new dataset search term
* Add a method to Dataset::Search::Definition that returns an example parameter
* Add the method name to the list of valids
* Update Dataset::Search::ParameterFactory to handle default value if needed
* Update Dataset::Search::Solr#build_params to pass the new term to SOLR

### How to add a new facet
* Add a the facet field to SOLR first, be careful with the datatype.
* Add the new facet field to the facet fields array in the configuration file

### How to contact NSIDC

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

### License

Every file in this repository is covered by the GNU GPL Version 3; a copy of the
license is included in the file COPYING.
