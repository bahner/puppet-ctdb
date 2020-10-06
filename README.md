# ctdb

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with ctdb](#setup)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Development - Guide for contributing to the module](#development)

## Description

Configuring ctdb can be a little daunting at first. When I got it to work
I created this module and forgot about it. I see that many have downloaded
and figured it could use a brush up.

## Setup

It mainly just installs the package and configure the bare necessities.
ctdb is a cluster tdb, which is the backend for a local Samba installation
without AD integration. So it stores user accounts and what have you.
When running you can add users to just one of the servers and have all
the Samba servers in the cluster pick up on the change.

### Setup Requirements

A shared file system is required. You *must* have such a filesystem, whether
SMB of NFS where the cluster lock can be stored. This is so important the no
default is given for the recovery_lock file, which must reside on this
shared filesystem, that all cluster members must have access to.

## Usage

You need at least to configure where the lock file is stored.

You *must* provide a list of ip adresses, the nodes_list which 
the cluster members can use to see each other.

You *must* provide the public addresses the cluster you create. If one
server goes down the others will start answering on these adresses.
It's DNS Round Robin all the way. *Secundum non datur*.
ctdb wotks by keeping all of these IPs up and running across the cluster.
You then you DNS round robin to spread load between them or something
like that.

So either you populate the nodes_list and public_addresses files yourself,
or you provide the correct ip/interface pairs and ip list to the module.
Using the module is probably the best. Look at the [REFERENCE.md](REFERENCE.md) for examples.

The following Hiera example demonstrates usage.
```yaml
---
ctdb::recovery_lock: /Shared/files/system/ctdb.lock
ctdb::nodes:list:
  - 10.0.0.2
  - 10.0.0.4
  - 10.0.0.6
  - 10.0.0.8
  - 10.0.0.10
ctdb::public_addresses_list:
  - '10.0.0.1 eth0'
  - '10.0.0.3 eth0'
  - '10.0.0.5 eth0'
  - '10.0.0.7 eth0'
  - '10.0.0.9 eth0'
  - '1.2.3.4  eth1'
  - '1.2.3.5  eth1'
ctdb::manages_samba: true
ctdb::manages_winbind: true
ctdb::manages_nfs: true
ctdb::max_open_files: 10
ctdb::logging: file:/var/log/log.ctdb
ctdb::debuglevel: ERR
ctdb::set_tdb_mutex_enabled: 1
ctdb::samba_skip_share_check: true
```

## Development

Pull requests are welcome, so are issues.

## Release Notes

Pending changelog bug to be fixed. Nothing note worthy.

2020-10-07: bahner
