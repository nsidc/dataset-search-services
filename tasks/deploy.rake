require_relative '../config/app_config'

def run_vagrant_ssh(env, ssh_cmd)
  cmd = "vagrant nsidc ssh --env=#{env} -c '#{ssh_cmd}'"
  puts "Running #{cmd}"

  `#{ cmd }`
end

# I want to run `vagrant nsidc up --env=blue` and
# make the app think its env=='production'
def app_env(args_env)
  args_env == 'blue' ? 'production' : args_env
end

namespace :deploy do
  # Do some file system manipulation to make sure that the app exists in
  # the app path, and that puma is ready to configure and start up.
  task :setup_machine, [:env] do |_t, args|
    run_vagrant_ssh(args[:env], "sudo rm -rf #{AppConfig::APP_PATH}; "\
                                "sudo mkdir -p #{AppConfig::APP_PATH}; "\
                                "cd #{AppConfig::APP_PATH}; "\
                                'sudo cp -R /vagrant/* .; '\
                                'sudo chown -R vagrant .; '\
                                'bundle install')
  end

  task :configure_puma, [:env] => :setup_machine do |_t, args|
    puma_config = File.join(AppConfig::APP_PATH, 'deployment/puma.conf')
    env_config = File.join(AppConfig::APP_PATH, 'config/environment')

    run_vagrant_ssh(args[:env], "sudo cp #{puma_config} /etc/init/; "\
                                "mkdir -p #{File.join(AppConfig::APP_PATH, 'run/log')}; "\
                                "sudo chown vagrant #{File.join(AppConfig::APP_PATH, 'config')}; "\
                                "echo '#{app_env(args[:env])}' > #{env_config}")
  end

  task :start_puma, [:env] => :configure_puma do |_t, args|
    run_vagrant_ssh(args[:env], 'sudo service puma restart')
  end
end
