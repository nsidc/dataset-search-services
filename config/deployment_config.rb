require File.join(File.dirname(__FILE__), 'app_config')

module DeploymentConfig
  def self.deployment_log(env)
    key = env.is_a?(String) ? env.to_sym : env
    DEPLOYMENT_LOG[key]
  end

  def self.server_for_environment(env)
    key = env.is_a?(String) ? env.to_sym : env
    ENVIRONMENTS[key]
  end

  def self.[](key)
    key = key.is_a?(String) ? key.to_sym : key
    DEPLOYMENT_SETTINGS[key]
  end

  private

  ENVIRONMENTS = {
      integration: 'liquid',
      qa: 'brash',
      staging: 'freeze',
      production: 'frozen'
  }

  DEPLOYMENT_SETTINGS = {
      app_name: AppConfig::APPLICATION_NAME,
      deployment_directory: AppConfig::APPLICATION_NAME,
      artifact_repo: "/disks/integration/san/INTRANET/REPO/#{AppConfig::APPLICATION_NAME}",
      deployment_log: "/disks/integration/san/INTRANET/REPO/#{AppConfig::APPLICATION_NAME}/deployable_versions_vm",
      deploy_dirs: %w(config lib config.ru Gemfile Gemfile.lock README.md deployment)
  }

  DEPLOYMENT_LOG = {
      compile_and_deploy: 'deployable_versions_integration',
      integration: 'deployable_versions_qa',
      qa: 'deployable_versions_staging',
      staging: 'deployable_versions_production',
      production: 'deployed_versions_production',
      vm: 'deployable_versions_vm'
  }
end
