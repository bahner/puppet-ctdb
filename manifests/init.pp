# @summary Configure a cdtb cluster
#
# Using this class the necessities for getting a ctdb 
# cluster up and running should be within grasp.
# It mostly makes sure the base necessities are met,
# but some everyday settings are included.
#
# Batteries are not.
#
# @example Minimum invocation
#   class { 'ctdb':
#     recovery_lock    => '/data/glusterfs/ctdb/lock',
#   }
# @example A mostly full invocation
#   class { 'ctdb':
#     recovery_lock         => '/gluster/lock/lockfile',
#     public_addresses      => '/usr/local/etc/ctdb.public.adresses',
#     public_addresses_list => [
#       '10.0.0.1 eth0',
#       '10.0.0.3 eth0',
#       '10.0.0.5 eth0',
#       '10.0.0.7 eth0',
#       '10.0.0.9 eth0',
#       '1.2.3.4  eth1',
#       '1.2.3.5  eth1',
#     ],
#     nodes                 => '/usr/local/etc/ctdb.nodes',
#     nodes_list            => [
#       '10.0.0.2',
#       '10.0.0.4,
#       '10.0.0.6,
#       '10.0.0.8,
#       '10.0.0.10,
#     ],
#     max_open_files        => 1000000,
#     set_tdb_mutex_enabled => 1,
#
# @param recovery_lock
#   Some file path on a shared storage. This is requred.
#   Default for this module is /gluster/locki/lockfile -
#   but this is arbitrary. This needs to rest on a
#   filesystem shared by all cluster nodes.
# @param public_addresses
#   File with a list of public addresses this host is
#   willing to hold. One per line in the form of:
#     IPADDR/PREFIX IFNAME
#   eg.
#     1.2.3.4/24 eth0
#     1.8.8.8/30 eth0
# @param public_addresses_list
#   The actual list (contents of public_addresses). An array
#   with one entry for each line in file.
#   If this array is not filled you *must* populate the file
#   yourself.
#   Example: ["1.2.3.4/24 eth0", "1.8.8.8/30 eth2"]
# @param nodes
#   File with simple list on initial cluster members. One per line.
#   Default: /etc/ctdb/nodes
# @param nodes_list
#   Array with list on initial cluster members.
#   Example: ["192.168.0.1", "192.168.0.2"]
#   These address must not overlap with the public addresses
#   in the sense that no one address can be the same, BUT
#   they can all be in the same subnet.
#
#   If this array is not given, you must populate the file 
#   by yourself.
# @param manages_samba
#   Whether or not to manage samba service. Default is no.
# @param manages_winbind
#   Whether or not to manage winbind service. Default is no.
# @param manages_nfs
#   Whether or not to manage NFS service. Default is no.
# @param max_open_files
#   Maximum number files to hold open.
# @param logging
#   Pseudo URL for where to log. Default is file:/var/log/log.ctdb
#     file:/var/log/log.ctdb
#     syslog:nonblocking
#     syslog:udp-rfc5424
#     syslog:udp
# @param debuglevel
#   Loglevel. Possible values are:
#     - ERR
#     - WARNING
#     - NOTICE
#
#     Default: NOTICE
# @param set_tdb_mutex_enabled
#   Enables TDB mutexes which are more efficient than posix locks,
#   if available. Use 0 or 1 as truthy value.
# @param samba_skip_share_check
# Whether or not to check the gluster share. Shares are not system paths,
# so when using gluster shares this must be set.
#
class ctdb (

  Stdlib::Absolutepath $recovery_lock,
  Optional[Stdlib::Absolutepath] $public_addresses,
  Optional[Stdlib::Absolutepath] $nodes,

  Optional[Array] $public_addresses_list,
  Optional[Array] $nodes_list,

  Optional[Boolean] $manages_samba,
  Optional[Boolean] $manages_winbind,
  Optional[Boolean] $manages_nfs,
  Optional[Boolean] $samba_skip_share_check,

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
        File['ctdbd.conf'],
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

  if $nodes and $nodes_list {
    file {
      'nodes_list':
        ensure  => file,
        path    => $nodes,
        content => epp('ctdb/nodes.epp'),
        notify  => Service['ctdb'],
      ;
    }
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
