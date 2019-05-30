# Load modules and classes
lookup('classes', {merge => unique}).include

# Ensure the brightbox apt repository gets added before installing ruby
include apt
apt::ppa{'ppa:brightbox/ruby-ng':}

package { 'ruby2.2':
  ensure => present,
  require => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
} ->
package { 'ruby2.2-dev':
  ensure => present
} ->
exec { 'install bundler':
  command => 'sudo gem install bundler -v 1.10.3',
  path => '/usr/bin'
} ->

# puma native extension dep
package { 'libssl-dev':
  ensure => present
} ->

# nokogiri native extension dep
package { 'zlib1g-dev':
  ensure => present
}

# vagrant must be able to write to /var/log
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

file { '/var/log':
  path => '/var/log',
  ensure => directory,
  group => 'syslog'
}

file { '/var/run/puma':
  path => '/var/run/puma',
  ensure => directory,
  mode => 775,
  group => 'syslog'
}
