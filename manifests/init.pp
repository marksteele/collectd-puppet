class collectd (
  $config = {},
  $core_plugins = undef,
  $perl_engine_config = {},
  $perl_plugin_config = {},
  $perl_plugins = undef
) {

    # Hiera deep merge magic
    if $core_plugins != undef {
        $collectd_core_plugins = hiera_hash('collectd::core_plugins')

        validate_hash($collectd_core_plugins)
    }

    if $perl_plugins != undef {
        $collectd_perl_plugins = hiera_hash('collectd::perl_plugins')

        validate_hash($collectd_perl_plugins)
    }

    $package_list = [ 'collectd', 'collectd-dev' ]

    if ! defined(Package['libwww-perl']) {
      package { 'libwww-perl':
        ensure => 'present',
        require => Package['collectd']
      }
    }

    if ! defined(Package['libjson-perl']) {
      package { 'libjson-perl':
        ensure => 'present',
        require => Package['collectd']
      }
    }

    if ! defined(Package['libsys-cpu-perl']) {
      package { 'libsys-cpu-perl':
        ensure => 'present',
        require => Package['collectd']
      }
    }

    if ! defined(Package['libperl-dev']) {
      package { 'libperl-dev':
        ensure => 'present',
        require => Package['collectd']
      }
    }

    if ! defined(Package['libdbd-mysql-perl']) {
      package { 'libdbd-mysql-perl':
        ensure => 'present',
        require => Package['collectd']
      }
    }

    package { $package_list:
      ensure => 'present'
    }

    service { "collectd":
      ensure => running,
      enable => true,
      hasrestart => true,
      pattern => collectd,
      require => Package['collectd']
    }

    file { "/etc/collectd/collectd.conf":
      ensure => present,
      mode => 0644,
      owner => root,
      group => root,
      content => template('collectd/collectd.conf.erb'),
      require => Package['collectd'],
      notify => Service['collectd'],
    }

    file { "/etc/collectd/":
      ensure => present,
      mode => 0644,
      recurse => true,
      force => true,
      purge => true,
      owner => root,
      group => root,
      notify => Service['collectd'],
      require => Package['collectd'],
    }

    file { "/usr/lib/collectd/Collectd":
      ensure => directory,
      mode => 0644,
      owner => root,
      group => root,
      recurse => true,
      purge => true,
      require => Package['collectd'],
    }

    file { "/usr/lib/collectd/Collectd/Plugins":
      ensure => directory,
      mode => 0644,
      owner => root,
      group => root,
      recurse => true,
      purge => true,
      source => "puppet:///modules/collectd/collectd-plugins",
      require => Package['collectd'],
    }

    file { "/etc/default/collectd":
      ensure => present,
      mode => 0644,
      owner => root,
      group => root,
      source => "puppet:///modules/collectd/etc_default_collectd",
      require => Package['collectd'],
      notify => Service['collectd'],
    }

    file { "/usr/share/collectd/types.db":
      ensure => present,
      mode => 0644,
      owner => root,
      group => root,
      source => "puppet:///modules/collectd/types.db",
      require => Package['collectd'],
      notify => Service['collectd'],
    }

}
