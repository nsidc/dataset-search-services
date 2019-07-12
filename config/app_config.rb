# basic configuration for the application
require('yaml')

module AppConfig
  APPLICATION_NAME = 'dataset-search-services'
  APP_PATH = '/opt/search_services'
  APP_CONFIGS = YAML.load_file(File.expand_path('../app_config.yaml', __FILE__))

  def self.[](env = :development)
    env = env.to_sym
    app_config = case env
                 when :development, :test
                   APP_CONFIGS[:development]
                 else
                   APP_CONFIGS[:common].merge(APP_CONFIGS[env])
                 end

    query_config_file = env == :test ? '../solr_query_config_test.yml' : '../solr_query_config.yml'
    app_config[:query_config] = YAML.load_file(File.expand_path(query_config_file, __FILE__))
    app_config
  end
end
