# Class: ctdb
# ===========================
#
# Full description of class ctdb here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# @param recovery_lock
#   Some file path on a shared storage. This is requred.
#   Default for this module is /gluster/lock - but this 
#   is arbitrary. This needs to rest on a filesystem
#   shared by all cluster nodes.
#
# @param public_addresses
#   File with a list of public addresses this host is
#   willing to hold.
#   Format per line is:
#
#     IPADDR/PREFIX IFNAME
#   
#   eg.
#     1.2.3.4/24 eth0
#     1.8.8.8/30 eth0
#
# @param public_addresses_list
#   The actual list (contents of public_addresses). An array
#   with one entry for each line in file.
#
# @param nodes
#   File with simple list on initial cluster members.
#   Default: /etc/ctdb/nodes
#
#   eg.
#     1.2.3.4
#     1.8.8.8
#
# @param manages_samba
#   Whether or not to manage samba service. Default is no.
#
# @param manages_winbind
#   Whether or not to manage winbind service. Default is no.
#
# @param manages_nfs
#   Whether or not to manage NFS service. Default is no.
#
# @param max_open_files
#   Maximum number files to hold open.
#
# @param logging
#   Pseudo URL for where to log. Default is file:/var/log/log.ctdb
#     file:/var/log/log.ctdb
#     syslog:nonblocking
#     syslog:udp-rfc5424
#     syslog:udp
#
# @param debuglevel
#   Loglevel. Possible values are:
#     - ERR
#     - WARNING
#     - NOTICE
#
# @param set_tdb_mutex_enabled
#   Enables TDB mutexes which are more efficient than posix locks,
#   if available. Use 0 or 1 as truthy value.
#
# Examples
# --------
#
# @example
#    class { 'ctdb':
#      recovery_lock    => '/data/glusterfs/ctdb/lock',
#      public_addresses => '/etc/ctdb/public_addresses'
#      manages_samba    => true,
#    }
#
# Authors
# -------
#
# Lars Bahner <lars.bahner@gmail.com>
#
# Copyright
# ---------
#
# Copyright © 2019 Lars Bahner
#
class ctdb (

  Optional[Stdlib::Absolutepath] $recovery_lock,
  Optional[Stdlib::Absolutepath] $public_addresses,
  Optional[Stdlib::Absolutepath] $nodes,

  Optional[Array] $public_addresses_list,

  Optional[Boolean] $manages_samba,
  Optional[Boolean] $manages_winbind,
  Optional[Boolean] $manages_nfs,

  Optional[Integer] $max_open_files,

  Optional[String] $logging,
  Optional[Enum['ERR','WARNING','NOTICE']] $debuglevel,
  
  Optional[Integer] $set_tdb_mutex_enabled,
) {

  package {
    'ctdb':
      ensure => installed,
    ;
  }

  service {
    'ctdb':
      ensure  => running,
      require => [
        Package['ctdb'],
        File[
          'ctdbd.conf',
          'public_addresses',
        ],
      ],
    ;
  }

  file {
    'ctdbd.conf':
      ensure  => file,
      content => epp('ctdb/ctdbd.conf.epp'),
      notify  => Service['ctdb'],
      path    => '/etc/ctdb/ctdbd.conf',
    ;
  }

  if $public_addresses_list and $public_addresses {
    file {
      'public_addresses':
        ensure  => file,
        path    => $public_addresses,
        content => epp('ctdb/public_addresses.epp'),
        notify  => Service['ctdb'],
      ;
    }
  }
}
