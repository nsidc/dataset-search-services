# NSIDC Open Search

## Development Environment and Workflow

### Git workflow

Development on this project uses
[the GitHub Flow](https://guides.github.com/introduction/flow/index.html):

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Stage your changes (`git add`)
3. Commit your RuboCop-compliant and test-passing changes with a
   [good commit message](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
   (`git commit`)
4. Push to the branch (`git push -u origin my-new-feature`)
5. [Create a new Pull Request](https://github.com/nsidc/dataset-search-services/compare)

### Installation & Usage

See
[`README.md`](https://github.com/nsidc/dataset-search-services/blob/master/README.md).

### Running a development instance

By default, the development environment tries to query a development version of
the machine running Solr. Modify the `:development:solr_url` and
`development:solr_auto_suggest_url` values in [app_config.yaml](./config/app_config.yaml)
to reflect the actual name of your development machine (or use the values from
the `integration` section of the configuration). Start up a local instance of
`dataset-search-services` with `bundle exec rake run`.

### Unit tests

Run the unit tests with `bundle exec rake spec:unit`.

### Acceptance tests

tl;dr:
* `export TARGET_ENVIRONMENT=integration`
* `bundle exec rake spec:acceptance`
* `bundle exec rake spec:acceptance[search_glacier]` (to run only the test tagged with `search_glacier`)

Acceptance tests refer to the `TARGET_ENVIRONMENT` environment variable to
determine the endpoints to be tested. If the environment variable is not set,
the target environment defaults to `development`, and you'll need to have an
instance of DSS running at `localhost:3000`. The method
[`OpenSearchSteps::full_hostname`](./spec/acceptance/steps/open_search_steps.rb)
generates the full DSS URL used to power the acceptance tests.

The acceptance tests are each tagged with a string starting with `osdd_` or
`search_` to facilitate Ops monitoring. Be sure to include a similar tag for
each new test you add (if you want Ops to monitor the behavior). To see all of
the tags:

    export LIST_TAGS=true; bundle exec rake spec:acceptance; unset LIST_TAGS

### RuboCop

[RuboCop](https://github.com/bbatsov/rubocop) is a style checker for Ruby,
designed to enforce rules specified in the community-driven
[Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide). Settings are
configured in `.rubocop.yml`. It can be run simply with `bundle exec rubocop`.

### Guard

Guard can be used to automatically restart the puma server or run RuboCop and unit tests whenever a file changes.

* `bundle exec rake guard:rubocop` - automatically re-run RuboCop
* `bundle exec rake guard:specs` - automatically re-run unit tests
* `bundle exec rake guard:puma` - automatically restart the puma server
* `bundle exec rake guard` - automatically re-run RuboCop and the unit tests

## Design

At the core of the service is a search definition. The definition includes a
method for each of the search terms terms as well as a list of valid term
combinations. This list of valids is used to generate Query and Url examples in
the OpenSearch description documents and to verify parameters in search
requests.

Complementing the definition is a search implementation. Implementations must
provide an execute method which accepts a hash of valid search term. Execute
methods must return an open search response builder.

### Class-responsibility-collaboration

* `Dataset::Search::Definition` - definition of terms for a dataset search
* `Dataset::Search::DefinitionSuggest` - definition of terms for an auto-suggest search
* `Dataset::Search::SolrSearch` - implementation that executes a SOLR query and
  returns a set of matching datasets or facets using the parser and response
  builder passed to its instance.
    * `RSolr`
    * `RSolr::Ext`
    * `Dataset::Model::Search::OpenSearchResponseBuilder` /
      `Dataset::Model::Facets::FacetsResponseBuilder`
    * `Dataset::Search::SolrResultsParser` / `Dataset::Search::SolrFacetsParser`
* `Dataset::Search::SolrSearch` - implementation that executes a SOLR query and
  returns a set of matching auto-suggest completions using the parser and
  response builder passed to its instance.
    * `RSolr`
    * `Dataset::Model::Suggestions::SuggestionResponseBuilder`
    * `Dataset::Search::SolrSuggestionsParser`

* `Dataset::Search::ResultsParameterFactory` - generates a hash of search
  parameters based on parameters from the request and a list of valids
* `Dataset::Search::FacetsParameterFactory` - generates a hash of search
  parameters based on parameters from the request and a list of valids. Sets
  `:facets` to `true` and `count` to 0 since we just want the facets.
* `Dataset::Search::SuggestionsParameterFactory` - generates a hash of search
  parameters based on parameters from the request and a list of valids
* `Dataset::Model::Search::OpenSearchResponseBuilder` - results of a dataset
  search which can be serialized to ATOM
    * `Dataset::Model::Search::ResultEntry`
* `Dataset::Model::Search::ResultEntry` - a single dataset in the results
* `Dataset::Model::Facets::FacetsResponseBuilder` - results of a faceted search
  which can be serialized to ATOM
    * `Dataset::Model::Facets::FacetEntry`
* `Dataset::Model::Facets::FacetEntry` - a single facet in the results
* `Dataset::Model::Suggestions::SuggestionsResponseBuilder` - results of a
  suggestion search which can be serialized to JSON based on the
  [OpenSearch Extension](https://github.com/dewitt/opensearch/blob/master/mediawiki/Specifications/OpenSearch/1.1/Draft%205.wiki)
    * `Dataset::Model::Suggestions::SuggestionEntry`
* `Dataset::Model::Suggestions::SuggestionEntry` - a single suggestion for the
  searched upon term. Contains just completion suggestion, but with the
  OpenSearch Suggestion standard can optionally contain a description (like
  number of results the full query with this completion would return) and the
  full URL to execute the search using the completion.
* `DatasetSearch` - specifies the definition, parameter factory, and
  implementation to use in a search query (parser and builder)
    * `Dataset::Search::Definition`
    * `Dataset::Search::SolrSearch`
    * `Dataset::Search::ResultsParameterFactory`
    * `Dataset::Search::SolrResultsParser`
    * `Dataset::Model::Search::OpenSearchResponseBuilder`
    * `Search`
* `DatasetFacets` - specifies the definition, parameter factory, and
  implementation to use in a faceted query (parser and builder)
    * `Dataset::Search::Definition`
    * `Dataset::Search::SolrSearch`
    * `Dataset::Search::FacetsParameterFactory`
    * `Dataset::Search::SolrFacetsParser`
    * `Dataset::Model::Facets::FacetsResponseBuilder`
    * `Search`
* `DatasetSuggestions` - specifies the definition, parameter factory, and
  implementation to use in a faceted query (parser and builder)
    * `Dataset::Search::DefinitionSuggest`
    * `Dataset::Search::SolrSearchSuggest`
    * `Dataset::Search::SuggestParameterFactory`
    * `Dataset::Search::SolrSuggestionsParser`
    * `Dataset::Model::Suggestions::SuggestionsResponseBuilder`
    * `Search`
* `Search` - implementation of the search algorithm: validate inputs, execute
  search, enrich results
    * `Validator`
    * `SearchAdapter`
    * `Enricher`
* `Validator` - validate search inputs with a given search definition
* `SearchAdapter` - executes a search by calling the execute method of a given
  search implementation with the parameters from a given parameter factory
* `Enricher` - updates each result entry with a given set of entry enrichers
* `App` - the main application
    * `Sinatra::Base`
    * `Controllers::DatasetOsdd`
    * `Controllers::DatasetSearch`
    * `Controllers::DatasetFacets`
    * `Controllers::DatasetSuggestions`
* `Routes` - contains a list of named routes supported by the application
* `DatasetOsdd` - implements an OpenSearch description document for dataset
  searches
    * `Dataset::Search::Definition`
    * `Routes`
* `Controllers::DatasetOsdd` - handler for OpenSeachDescription requests
    * `DatasetOsdd`
    * `Routes`
    * `Sinatra`
* `Controllers::DatasetSearch` - handler for OpenSearch requests
    * `DatasetSearch`
    * `Routes`
    * `Sinatra`
* `Controllers::DatasetFacets` - handler for Faceted requests
    * `DatasetFacets`
    * `Routes`
    * `Sinatra`
* `Controllers::DatasetSuggestions` - handler for Suggestion requests
    * `DatasetSuggestions`
    * `Routes`
    * `Sinatra`


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

* Add a method to `Dataset::Search::Definition` that returns an example
  parameter
* Add the method name to the list of valids
* Update `Dataset::Search::ParameterFactory` to handle default value if needed
* Update `Dataset::Search::Solr#build_params` to pass the new term to SOLR

### How to add a new facet

* Add a the facet field to SOLR first, be careful with the datatype.
* Add the new facet field to the facet fields array in the configuration file

### Search Relevance Ranking

Search ranking configurations can be found in config/solr_query_config_*.yml

The configuration for relevance ranking includes 'query_field_boosts',
'phrase_field_boosts', 'boost_query', and 'boost'.  The numbers associated with
each field are the boost values that indicate how closely the field should match
the query. Higher numbers will cause the result to be ranked higher when the
query terms match the field. It is possible to increase or decrease the field
boost values to alter the ranking of results but be advised that it will affect
all search results.

The 'boost_query' and 'boost' configurations boost the results based on other
fields like popularity. There are comments in the configuration files that
explain what each value is doing. Popularity is not the only factor in how
results are ranked, but new datasets have a popularity that defaults to 5 (on a
scale from 1-11). Increase or decrease the popularity value if the ranking of a
specific dataset is not in the desired order.

For more information on Solr relevance tuning, see the [Solr Reference "Query
Guide" Chapter](https://solr.apache.org/guide/solr/latest/query-guide/query-syntax-and-parsers.html).
