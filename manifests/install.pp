# == Class: autossh::install
#
# This class initilises the runtime environment for the autossh package and
# should not be called directly as it is called from the class initialiser.
#
# === Parameters
#
# === Variables
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
class autossh::install {
  $user                   = $autossh::user
  $package_ensure         = $autossh::pakage_ensure
  $package_name           = $autossh::package_name
  $ssh_reuse_established_connections =
    $autossh::ssh_reuse_established_connections
  $ssh_enable_compression = $autossh::ssh_enable_compression
  $ssh_ciphers            = $autossh::ssh_ciphers
  $ssh_stricthostkeychecking = $autossh::ssh_stricthostkeychecking
  $ssh_tcpkeepalives = $autossh::ssh_tcpkeepalives
  $home              = $autossh::home

  ## If the target user account doesn't exist, create it...
  if ! defined(User[$user]) {
    user { $user:
      managehome => true,
      system     => true,
      shell      => '/bin/bash',
    }
  }

  if ! defined(File["${home}/.ssh"]) {
    file { "${home}/.ssh":
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0700'
    }
  }


  if !defined(File['auto_ssh_conf_dir']) {
    file{'auto_ssh_conf_dir':
      ensure => directory,
      path   => '/etc/autossh',
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }
  }

  case $::osfamily {
    /RedHat/: {
      # redhat-lsb-core is not supporte on rhel 7...
      case $::operatingsystemmajrelease {
        /6/: {
          if(!defined(Package['redhat-lsb-core'])) {
            package{'redhat-lsb-core':
              ensure => installed,
              before => Package['autossh'] }
          }
        } # case rhel 6
        /7/: {
          file{'autossh-tunnel.sh':
            ensure  => 'present',
            path    => '/etc/autossh/autossh-tunnel.sh',
            mode    => '0750',
            owner   => 'root',
            group   => 'root',
            content => template('autossh/autossh.init.systemd.erb'),
            replace => yes,
          }
        } # case rhel 7
        default: {
        }
      }

      # required on all rhel platforms
      if(!defined(Package['openssh-clients'])) {
        package{'openssh-clients': ensure => installed }
      }
    } #case RedHat
  } #case

  package { $package_name:
    ensure => $package_ensure,
  }


  ## Configure reuse of established connections.
  ## Nice but little known feature of ssh.
  if $ssh_reuse_established_connections {
    file { "${home}/.ssh/sockets":
      ensure => directory,
      owner  => $user,
      group  => $user,
      mode   => '0700'
    }
  }

  ##
  ## ssh config file
  ##
  concat { "${home}/.ssh/config":
    owner => $user,
    group => $user,
    mode  => '0600',
  }

  ##
  ## Global Settings
  ##
  $remote_ssh_host = '*'
  concat::fragment { "home_${user}_ssh_config_global":
    target  => "${home}/.ssh/config",
    content => template('autossh/config.erb'),
    order   => 10,
  }
}
