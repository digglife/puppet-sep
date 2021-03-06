# == Class: sep
#
# checking Symantec Endpoint Protection status.
#
# === Parameters
#
#
# [*$source*]
#   The UNC path of SEP installer. Make sure sep64.exe and sep32.exe exists.
# 
# [*$deploy_sylink*]
#   true or false. You have to place the sylink.xml exported from SEPM to files
#   folder.
#
# [*$sepm_ip*]
#   The IP address of SEPM server. It's required if $deploy_sylink is true.
#
#
# === Examples
#
#  class { 'sep':
#    $sep_package_source => '\\9.123.108.55\share',
#    $deploy_sylink = true,
#    $sepm_ip = '9.123.108.133',
#  }
#
# === Authors
#
# Zhu Sheng Li <digglife@gmail.com>
#
# === Copyright
#
# Copyright 2015 Zhu Sheng Li.
#
class sep (
  $source,
  $deploy_sylink = false,
  $sepm_ip = undef,
) {

  if $::architecture =~ /64/ {
    $sep_package = "${source}\\sep64.exe"
  } else {
    $sep_package = "${source}\\sep32.exe"
  }

  #Actually Puppet is unable to manipulate sepmasterservice
  #if the tamper protection is checked(default).
  #This behavior could be changed from SEPM.
  service { 'SepMasterService':
    ensure => 'running',
    enable => true,
    require => Package['sep'],
  }

  package { 'sep':
    name   => 'Symantec Endpoint Protection',
    ensure => installed,
    source => $sep_package,
  }

  if $deploy_sylink and $sepm_ip and $::sep {
    if $::sep[sepm] != $sepm_ip or !$::sep[online]  {
      file { 'sylinkfile':
        ensure => present,
        path => "C:\\Windows\\Temp\\sylink.xml",
        source => 'puppet:///modules/sep/sylink.xml',
        source_permissions => ignore,
      }

      exec { 'update_sepm':
        command => "\"${::sep[path]}\\sylinkdrop.exe\" -silent C:\\Windows\\Temp\\sylink.xml",
        subscribe => File['sylinkfile'],
        refreshonly => true,
        notify => Service['SepMasterService'],
      }
    }
  }
}
