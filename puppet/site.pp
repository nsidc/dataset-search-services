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

### BEGIN nokogiri deps
class update-package-manager {
  exec { "update":
    path => "/bin:/usr/bin:/usr/local/bin:/usr/local/sbin:usr/sbin:/sbin:/usr/java/jdk/bin",
    command => "apt-get -y update; sudo apt-get -y install libxml2 libxml2-dev libxslt1-dev"
  }
  notify { "apt-get update complete":
    require => Exec['update']
  }
}

Class['update-package-manager'] -> Package <| |>

package {"libssl-dev":
  ensure => present
} ->
package {"build-essential":
  ensure => present
} ->
package {"libxml2-dev":
  ensure => present
}

include update-package-manager
### END nokogiri deps

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