# Load modules and classes
hiera_include('classes')

# Ensure the brightbox apt repository gets added before installing ruby
include apt
apt::ppa{'ppa:brightbox/ruby-ng':}
class {'ruby':
  require         => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ],
  version => '1.9.3',
  set_system_default => true
}
class {'ruby::dev':
  require         => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
}

package {"libssl-dev":
  ensure => present
} ->
package {"build-essential":
  ensure => present
} ->
package {"libxml2-dev":
  ensure => present
}

# vagrant must be able to write to /var/log
user { 'vagrant':
  groups  => ['syslog'],
  ensure  => present
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
