# Load modules and classes
hiera_include('classes')

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
