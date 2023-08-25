# Load modules and classes
lookup('classes', {merge => unique}).include

$project = 'search_services'
$app_root = "/opt/${project}"
$ruby_ver = '3.2.2'
$bundler_ver = '2.4.10'
$rubygems_ver = '3.4.10'

package {"libssl-dev":
  ensure => present
} ->
package {"build-essential":
  ensure => present
} ->
class { 'rbenv':
  install_dir => '/home/vagrant/rbenv',
  owner => 'vagrant',
  group => 'vagrant',
}
-> rbenv::plugin { 'rbenv/ruby-build': }
-> rbenv::build { $ruby_ver:
  bundler_version => $bundler_ver,
  owner => 'vagrant',
  group => 'vagrant',
  global => true,
}
-> rbenv::gem { 'builder': ruby_version => $ruby_ver }
-> exec { 'gem_update':
  command => "gem update --system ${rubygems_ver}",
  path    => ['/home/vagrant/rbenv/shims', '/usr/local/bin','/usr/bin', '/bin'],
}
# puma native extension dep
# package { 'libssl-dev':
#   ensure => present
# } ->

# nokogiri native extension dep
# package { 'zlib1g-dev':
#   ensure => present
# }


# vagrant must be able to write to /var/log
# TODO: Is this stuff still necessary
if $environment == 'ci' {
  exec {'vagrant syslog membership':
    unless => '/bin/grep -q "syslog\\S*vagrant" /etc/group',
    command => '/usr/sbin/usermod -aG syslog vagrant',
    require => User['vagrant']
  }
} else {
  user { 'vagrant':
    groups  => ['syslog'],
    ensure  => present
  }
}

file { '/var/run/puma':
  path => '/var/run/puma',
  ensure => directory,
  mode => '775',
  group => 'syslog'
}
## END OF TODO QUESTION


unless $environment == 'ci' {
  # nginx configuration

  class { 'nginx' :
    gzip => 'off'
  }

  exec { 'make_cert':
    path => ['/bin', '/usr/bin'],
    command => 'mkdir -p /etc/nginx/ssl && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/CN=nsidc"'
  } ->
  nginx::resource::vhost { 'dss' :
    www_root => $application_root,
    proxy => 'http://localhost:10680',
    ssl => true,
    ssl_cert => '/etc/nginx/ssl/nginx.crt',
    ssl_key => '/etc/nginx/ssl/nginx.key',
  }


  # Install puma
  # See https://github.com/nsidc/puppet-puma
  # Note: port value is also set in config/app_config.rb
  include puma

  $puma_environment = $environment ? {
    'blue'  => 'production',
    'dev'   => 'development',
    default => $environment
  }

  $workers = $environment ? {
    'dev' => '2',
    'integration' => '4',
    default => '10'
  }

  # install the app in /opt/app_name
  file { 'create_deploy_directory':
    path => "${app_root}",
    ensure => directory,
    source => '/vagrant',
    recurse => true,
    ignore => "*puppet*",
    owner => 'vagrant',
    group => 'vagrant'
  } ->

  # install application gems
  exec { 'do_bundle_install':
    cwd     => "${app_root}",
    environment => "HOME=${app_root}",
    command => "bundle _${bundler_ver}_ install",
    path => ['/home/vagrant/rbenv/shims', '/usr/local/bin','/usr/bin', '/bin'],
    user => 'vagrant',
    group => 'vagrant',
    require => [ Exec['gem_update'] ]
  } ->

  puma::app {"${project}":
    app_name  => "${project}",
    app_root  => "${app_root}",
    puma_user => 'vagrant',
    www_user  => 'vagrant',
    env => {
      'RACK_ENV' => $puma_environment,
    },
    init_active_record => false,
    min_threads => '1',
    max_threads => '1',
    port => '10680',
    workers  => $workers,
    restart_command => '/home/vagrant/rbenv/shims/bundle exec puma',
    bundler_path => '/home/vagrant/rbenv/shims/bundle'
  } ->

  # Ensure directory for restart file exists
  file { "${app_root}/tmp":
    ensure => 'directory',
    owner => 'vagrant',
    group => 'vagrant',
    mode => '0755'
  } ->

  # Force puma restart when machine is reprovisioned
  file { "${app_root}/tmp/restart.txt":
    ensure => present,
    owner => 'vagrant',
    group => 'vagrant',
    content => generate('/bin/date')
  }
}
