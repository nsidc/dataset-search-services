# basic configuration for the application
require('yaml')

module AppConfig
  APPLICATION_NAME = 'dataset-search-services'

  def self.[](key)
    key_sym = key.to_sym unless key.nil?
    key_sym = :development if APPLICATION_ENVIRONMENTS[key_sym].nil?

    APPLICATION_ENVIRONMENTS[key_sym]
  end

  private

  COMMON = {
    enricher_thread_count: 5,
    relative_url_root: '/api/dataset/2',
    port: '10680',
    num_workers: 5,
    pidfile: '/opt/search_services/run/puma.pid',
    state_path: '/opt/search_services/run/puma.state',
    std_err_log: '/opt/search_services/run/log/puma.stderr.log',
    std_out_log: '/opt/search_services/run/log/puma.stdout.log'
  }

  APPLICATION_ENVIRONMENTS = {
    development: {
      enricher_thread_count: 5,
      relative_url_root: '/',
      solr_url: 'http://localhost:9283/solr/nsidc_oai',
      solr_auto_suggest_url: 'http://localhost:9283/solr/auto_suggest',
      dataset_catalog_services_url: 'http://integration.nsidc.org/api/dataset/metadata',
      metrics_url: 'http://liquid.colorado.edu:12180/metrics/projects/search/services/dataset-search-services/instances/integration',
      query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_integration.yml'))
    },
    integration: COMMON.clone.merge(
                                      solr_url: 'http://integration.solr-search.apps.int.nsidc.org:9283/solr/nsidc_oai',
                                      solr_auto_suggest_url: 'http://integration.solr-search.apps.int.nsidc.org:9283/solr/auto_suggest',
                                      dataset_catalog_services_url: 'http://integration.nsidc.org/api/dataset/metadata',
                                      metrics_url: 'http://liquid.colorado.edu:12180/metrics/projects/search/services/dataset-search-services/instances/integration',
                                      query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_integration.yml'))
                                    ),
    qa: COMMON.clone.merge(
                             solr_url: 'http://qa.solr-search.apps.int.nsidc.org:9283/solr/nsidc_oai',
                             solr_auto_suggest_url: 'http://qa.solr-search.apps.int.nsidc.org:9283/solr/auto_suggest',
                             dataset_catalog_services_url: 'http://qa.nsidc.org/api/dataset/metadata',
                             metrics_url: 'http://brash.colorado.edu:12180/metrics/projects/search/services/dataset-search-services/instances/qa',
                             query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_qa.yml'))
                           ),
    staging: COMMON.clone.merge(
                                  solr_url: 'http://staging.solr-search.apps.int.nsidc.org:9283/solr/nsidc_oai',
                                  solr_auto_suggest_url: 'http://staging.solr-search.apps.int.nsidc.org:9283/solr/auto_suggest',
                                  dataset_catalog_services_url: 'http://staging.nsidc.org/api/dataset/metadata',
                                  query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_production.yml'))
                                ),
    production: COMMON.clone.merge(
                                     solr_url: 'http://solr-search.apps.int.nsidc.org:9283/solr/nsidc_oai',
                                     solr_auto_suggest_url: 'http://solr-search.apps.int.nsidc.org:9283/solr/auto_suggest',
                                     dataset_catalog_services_url: 'http://nsidc.org/api/dataset/metadata',
                                     metrics_url: 'http://frozen.colorado.edu:12180/metrics/projects/search/services/dataset-search-services/instances/prod',
                                     query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_production.yml'))
                                   )
  }
end
