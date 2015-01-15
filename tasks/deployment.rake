task :init_server_env do
  if ENV['TARGET_ENVIRONMENT']
    @target_env = ENV['TARGET_ENVIRONMENT']
  else
    $stderr.puts 'Error: need TARGET_ENVIRONMENT environment variable to be set'
    exit 1
  end
  @server_path = "/disks/#{@target_env}#{DeploymentConfig[:app_dir]}"

  @server = NsidcDeploymentHelper::Server.new @target_env, DeploymentConfig.server_for_environment(@target_env), DeploymentConfig[:app_dir]
end

desc 'Create the supporting direcotry structure'
task install_server: :init_server_env do
  create_directory "#{@server_path}/run"
  create_directory "#{@server_path}/run/logs"
  create_directory "#{@server_path}/run/tmp"
  create_directory "#{@server_path}/webapps"

  `cp deployment/init #{@server_path}/init`
  `chgrp webapp #{@server_path}/init`
end

desc "Deploy the app's files from this workspace to the target environment"
task deploy_src_files: :init_server_env do
  dest = "#{@server_path}/webapps/#{DeploymentConfig[:app_name]}/"
  DeploymentConfig[:deploy_dirs].each do |file|
    FileUtils.cp_r file, "#{dest}/.", verbose: true
  end
end

desc "Deploy the app's tar file specified by an ARTIFACT_VERSION into the correct target directory"
task deploy_tar_file: :init_server_env do
  fail ArgumentError, 'No ARTIFACT_VERSION set' unless ENV.key? 'ARTIFACT_VERSION'
  artifact_id = ENV['ARTIFACT_VERSION']

  src = "#{DeploymentConfig[:artifact_repo]}/#{DeploymentConfig[:repo_dir]}/#{DeploymentConfig[:app_name]}-#{artifact_id}.tar"
  dest = "#{@server_path}/webapps/#{DeploymentConfig[:app_name]}.tar"

  puts "Copying #{src} to #{dest}..."
  `cp #{src} #{dest}`
  puts "untaring: tar -xvf --directory=#{@server_path}/webapps #{dest}"
  `tar -xvf #{dest} --directory=#{@server_path}/webapps`
  `chgrp -R webapp #{@server_path}/webapps/`
  `chmod -R 775 #{@server_path}/webapps/`
end

desc 'Print the application install location'
task print_app_location: :init_server_env do
  puts "#{@server_path}/webapps/#{DeploymentConfig[:app_name]}"
end

desc "Create and deploy this app's environment config file to the target directory"
task deploy_config_file: :init_server_env do
  setting_overrides = DeploymentConfig[:env_vars]
  settings = {
      'RACK_ENV' => @target_env
  }.merge(setting_overrides)

  filename = 'env'
  create_env_file filename, settings

  copy_env_file_to_server filename, @server_path
end

desc 'Stop the app'
task stop: :init_server_env do
  puts 'stopping'
  @server.stop
end

desc "Start the app'"
task start: :init_server_env do
  puts 'starting'
  @server.start
end

private

def create_directory(dir_name)
  `mkdir -p #{dir_name}` unless File.exist?(dir_name)
  `chgrp webapp #{dir_name}`
  `chmod 775 #{dir_name}`
end

def copy_env_file_to_server(filename, target_dir)
  puts "Copying to server at #{target_dir}..."
  `cp #{filename} #{target_dir}`
end

def create_env_file(filename, settings)
  puts 'Creating env file...'
  `echo "### This file provides TARGET_ENVIRONMENTal variables to init.\n" > #{filename}`

  settings.each do |setting, value|
    command = "export #{setting.to_s}='#{value}'"
    puts "Adding line to env file: #{command}"
    `echo "#{command}" >> #{filename}`
  end

  puts 'Making executable...'
  `chmod 775 #{filename}`
  `chgrp webapp #{filename}`
end

def run_command(cmd)
  IO.popen(cmd) { |f| puts f.gets }
end
