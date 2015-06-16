# basic configuration for the application
require('yaml')

module AppConfig
  APPLICATION_NAME = 'dataset-search-services'
  APP_PATH = '/opt/search_services'

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
    pidfile: '/var/run/puma/search_services.pid',
    state_path: '/var/run/puma/search_services.state',
    std_err_log: '/var/log/search_services.stderr.log',
    std_out_log: '/var/log/search_services.stdout.log'
  }

  APPLICATION_ENVIRONMENTS = {
    development: {
      enricher_thread_count: 5,
      relative_url_root: '/',
      solr_url: 'http://localhost:8983/solr/nsidc_oai',
      solr_auto_suggest_url: 'http://localhost:8983/solr/auto_suggest',
      dataset_catalog_services_url: 'http://integration.nsidc.org/api/dataset/metadata',
      metrics_url: 'http://liquid.colorado.edu:12180/metrics/projects/search/services/dataset-search-services/instances/integration',
      query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_integration.yml'))
    },
    integration: COMMON.clone.merge(
      solr_url: 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai',
      solr_auto_suggest_url: 'http://integration.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest',
      dataset_catalog_services_url: 'http://integration.nsidc.org/api/dataset/metadata',
      metrics_url: 'http://liquid.colorado.edu:12180/metrics/projects/search/services/dataset-search-services/instances/integration',
      query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_integration.yml'))
    ),
    qa: COMMON.clone.merge(
      solr_url: 'http://qa.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai',
      solr_auto_suggest_url: 'http://qa.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest',
      dataset_catalog_services_url: 'http://qa.nsidc.org/api/dataset/metadata',
      metrics_url: 'http://brash.colorado.edu:12180/metrics/projects/search/services/dataset-search-services/instances/qa',
      query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_qa.yml'))
    ),
    staging: COMMON.clone.merge(
      solr_url: 'http://staging.search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai',
      solr_auto_suggest_url: 'http://staging.search-solr.apps.int.nsidc.org:8983/solr/auto_suggest',
      dataset_catalog_services_url: 'http://staging.nsidc.org/api/dataset/metadata',
      query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_production.yml'))
    ),
    production: COMMON.clone.merge(
      solr_url: 'http://search-solr.apps.int.nsidc.org:8983/solr/nsidc_oai',
      solr_auto_suggest_url: 'http://search-solr.apps.int.nsidc.org:8983/solr/auto_suggest',
      dataset_catalog_services_url: 'http://nsidc.org/api/dataset/metadata',
      metrics_url: 'http://frozen.colorado.edu:12180/metrics/projects/search/services/dataset-search-services/instances/prod',
      query_config: YAML.load_file(File.join(File.dirname(__FILE__), 'solr_query_config_production.yml'))
    )
  }
end
