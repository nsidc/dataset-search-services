require 'yaml'

def solr_suggestion_response
  YAML.load_file(File.expand_path('../solr_suggestion_response.yaml', __FILE__))
end
