# basic configuration for the application
require('yaml')

module AppConfig
  APPLICATION_NAME = 'dataset-search-services'
  APP_PATH = '/opt/search_services'
  APP_CONFIGS = YAML.load_file(File.expand_path('../app_config.yaml', __FILE__))

  def self.[](env = :development)
    if env.to_sym == :development
      app_config = APP_CONFIGS[:development]
      query_config_env = :integration
    else
      app_config = APP_CONFIGS[:common].merge(APP_CONFIGS[env.to_sym])
      query_config_env = env
    end

    query_config_file = File.expand_path("../solr_query_config_#{query_config_env}.yml", __FILE__)
    app_config[:query_config] = YAML.load_file(query_config_file)

    app_config
  end
end
