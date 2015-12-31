# == Class: autossh::params
#
# This class defines the default values used in the autossh class.
# 
# === Parameters
#
# === Variables
#
# $user: The user account to be used to run autossh processes.
# $home: The user's home directory.
# $enable: enable/disable package support.
# $autossh_package: The package to be installed for autossh support.
# $pubkey: default pubkey.. not all that useful really.
# $tunnel_type: default tunnel type
# $remote_ssh_user: detault remote ssh user
# $remote_ssh_port: default remote ssh port number
# $forward_host: default host to forward requests to
# $bind: the local address to bind to
# $monitor_port: 0 default monitoring port number for autossh
# $ssh_reuse_established_connections: default enable reuse of already 
#              established ssh connections, if any.  Requires ssh > 5.5.
# $ssh_compression: enable/disable ssh compression 
# $ssh_ciphers: cipher selection ordering.  (fastest -> slowest)
# $ssh_stricthostkeychecking: enable/disable strict host key checking
# $ssh_tcpkeepalives: enable/disable tcp keepalives
#
# === Examples
#
#  class { autossh:
#  }
#
# === Authors
#
# Jason Ball <jason@ball.net>
#
# === Copyright
#
# Copyright 2014 Jason Ball.
#
class autossh::params {
  $package_name     = 'autossh'
  $package_ensure   = 'installed'
  $user             = 'autossh'
  $home             = "/home/${user}"
  $enable           = true
  $pubkey           = ''
  $tunnel_type      = 'forward'
  $remote_ssh_user  = 'autossh'
  $remote_ssh_port  = '22'
  $bind             = 'localhost'
  $forward_host     = 'localhost'
  $monitor_port     = '0'
  $ssh_reuse_established_connections = false  ## Requires openssh > v5.5
  $ssh_enable_compression = false ## Not really useful for local connections
  $ssh_ciphers =
    'blowfish-cbc,aes128-cbc,3des-cbc,cast128-cbc,arcfour,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr'
  $ssh_stricthostkeychecking = false
  $ssh_tcpkeepalives = true


  case $::osfamily {
    /RedHat/: {
      case $::operatingsystemmajrelease {
        /5|6/: {
          $init_template = 'autossh.init.sysv.erb'
        }
        /7/: {
          $init_template = 'autossh.init.systemd.erb'
        }
        default: {
          fail("Error - Unsupported OS Version: ${::operatingsystemrelease}")
        }
      } # $::operatingsystemmajrelease
    } # RedHat

    /Debian/: {
          $init_template = 'autossh.init.systemd.erb'
    }

    default: {
      fail("Unsupported Operating System: ${::osfamily}")
    }
  } # $::osfamily
}
