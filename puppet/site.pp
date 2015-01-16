# Load modules and classes
hiera_include('classes')

# Ensure the brightbox apt repository gets added before installing ruby
include apt
apt::ppa{'ppa:brightbox/ruby-ng':}
class {'ruby':
  require         => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
}
class {'ruby::dev':
  require         => [ Class['apt'], Apt::Ppa['ppa:brightbox/ruby-ng'] ]
}

Exec { path => "/bin:/usr/bin:/usr/local/bin:/usr/local/sbin:usr/sbin:/sbin:/usr/java/jdk/bin" }

class update-package-manager {
  exec { "update":
    command => "apt-get -y update"
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

package { "emacs": }
