# Load modules and classes
lookup('classes', {merge => unique}).include

$project = 'search_services'
$app_root = "/opt/${project}"
$ruby_ver = '3.4.9'
$bundler_ver = '4.0.10'
$rubygems_ver = '4.0.10'
$rbenv_home = '/home/vagrant'
$rbenv_dir = "${rbenv_home}/rbenv"

package {"libssl-dev":
  ensure => present
} ->
package {"build-essential":
  ensure => present
} ->
class { 'rbenv':
  install_dir => $rbenv_dir,
  owner       => 'vagrant',
  group       => 'vagrant',
  require     => User['vagrant'],
}
-> rbenv::plugin { 'rbenv/ruby-build': }
-> notify {'starting rbenv build': }
-> rbenv::build { $ruby_ver:
  bundler_version => $bundler_ver,
  owner => 'vagrant',
  group => 'vagrant',
  global => true,
}
-> notify {'done with rbenv build': }
-> file { "${rbenv_dir}/version":
  ensure => 'file',
  mode   => '0644',
  owner => 'vagrant',
  group => 'vagrant',
}
-> file { "${rbenv_dir}/shims/bundle":
  ensure => 'file',
  mode   => '0755',
  owner => 'vagrant',
  group => 'vagrant',
}

if ! defined (User['vagrant']) {
  @user { 'vagrant':
    ensure => present,
    groups => ['syslog', 'vagrant']
  }
} else {
  User <| title == 'vagrant' |> {
    groups => ['syslog', 'vagrant']
  }
}
realize(User['vagrant'])

unless $environment == 'ci' {
  exec { 'open port 443':
    command => 'iptables -A INPUT -p tcp --dport 443 -j ACCEPT',
    path => ['/usr/local/bin','/usr/bin', '/bin', '/usr/sbin'],
    user => 'root',
  } ->
  exec { 'save port changes':
    command => 'iptables-save --file /etc/iptables/rules.v4',
    path => ['/usr/local/bin','/usr/bin', '/bin', '/usr/sbin'],
    user => 'root',
  }

  # nginx configuration
  class { 'nginx' :
    gzip => 'off'
  }

  $nginx_hostname = $environment ? {
    'blue'       => "${project}.${domain}",
    'production' => "${project}.${domain}",
    default      => "${environment}.${project}.${domain}"
  }

  exec { 'make_cert':
    path => ['/bin', '/usr/bin'],
    command => 'mkdir -p /etc/nginx/ssl && openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt -subj "/CN=nsidc"'
  } ->
  nginx::resource::vhost { $nginx_hostname :
    # www_root => $app_root,
    ensure           => present,
    cors             => true,
    server_name      => [$nginx_hostname],
    ssl              => true,
    listen_port      => 443,
    ssl_port         => 443,
    ssl_cert         => '/etc/nginx/ssl/nginx.crt',
    ssl_key          => '/etc/nginx/ssl/nginx.key',
    proxy            => 'http://localhost:10680',
    proxy_set_header => [ 'Host $host',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto https' ],
    add_header       => {
      'Access-Control-Allow-Origin'  => '*',
      'Access-Control-Allow-Methods' => 'OPTIONS,HEAD,GET,PUT,POST,DELETE',
      'Access-Control-Allow-Headers' => 'Origin, X-Requested-With, Content-Type, Accept, Range'
    },
    proxy_read_timeout => '180',
    require => [ Exec['make_cert'] ]
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

  # Set this to the number of CPUs available, regardless of environment.
  # See VM configuration in Vagrantfile.
  $workers = '3'

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
    path => ["${rbenv_dir}/shims", '/usr/local/bin','/usr/bin', '/bin'],
    user => 'vagrant',
    group => 'vagrant',
    require => [ File["${rbenv_dir}/shims/bundle"] ],
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
    restart_command => "${rbenv_dir}/shims/bundle exec puma",
    bundler_path => "${rbenv_dir}/shims/bundle",
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
