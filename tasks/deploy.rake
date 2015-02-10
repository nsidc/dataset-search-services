def run_vagrant_ssh(env, ssh_cmd)
  cmd = "vagrant nsidc ssh --env=#{env} -c '#{ssh_cmd}'"
  puts "Running #{cmd}"

  `#{ cmd }`
end

namespace :deploy do
  # Do some file system manipulation to make sure that the app exists in
  # the app path, and that puma is ready to configure and start up.
  task :setup_machine, [:env] do |_t, args|
    run_vagrant_ssh(args[:env], "sudo mkdir -p #{ AppConfig::APP_PATH }")
    run_vagrant_ssh(args[:env], "sudo cp -R /vagrant/* #{ AppConfig::APP_PATH }")
    run_vagrant_ssh(args[:env], "sudo chown -R vagrant #{ AppConfig::APP_PATH }")
  end

  task :configure_puma, [:env] => :setup_machine do |_t, args|
    puma_config = File.join(AppConfig::APP_PATH, 'deployment/puma.conf')

    run_vagrant_ssh(args[:env], "sudo cp #{puma_config} /etc/init/")
    run_vagrant_ssh(args[:env], "mkdir -p #{File.join(AppConfig::APP_PATH, 'run/log')}")
    run_vagrant_ssh(args[:env], "sudo chown vagrant #{File.join(AppConfig::APP_PATH, 'config')}")
    run_vagrant_ssh(
      args[:env],
      # Blue should think it's production.
      "echo '#{args[:env].eql?('blue') ? 'production' : args[:env]}' > #{File.join(AppConfig::APP_PATH, 'config/environment')}"
    )
  end

  task :start_puma, [:env] => :configure_puma do |_t, args|
    run_vagrant_ssh(args[:env], 'sudo service puma start')
  end
end
