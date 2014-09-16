namespace :artifact do

  desc 'create the tar'
  desc 'Create a tarball of the necessary files for the acadis search project'
  task :package do
    files = DeploymentConfig[:deploy_dirs]
    NsidcDeploymentHelper::TarArtifact.create_tarball(AppConfig::APPLICATION_NAME, Version::VERSION, files)
  end

  desc 'Move the tar file to the repository, add build version to log'
  task :distribute, :environment do |_t, _args|
    NsidcDeploymentHelper::TarArtifact.distribute(AppConfig::APPLICATION_NAME, Version::VERSION, DeploymentConfig[:artifact_repo])
    NsidcDeploymentHelper::DeploymentLog.add_build_version_to_log(DeploymentConfig[:deployment_log], Version::VERSION)
  end

  desc 'Display the version id taken from the tar file'
  task :display_version_id, :environment do |_t, _args|
    version_id = NsidcDeploymentHelper::DeploymentLog.get_version_id(DeploymentConfig[:deployment_log])
    puts version_id
  end

  desc '[DEPRECATED: Use the distribute task instead.] Add the deployed version to the deployment log'
  task :add_build_version_to_log, :environment do |_t, _args|
    NsidcDeploymentHelper::DeploymentLog.add_build_version_to_log(DeploymentConfig[:deployment_log], Version::VERSION)
  end

end
