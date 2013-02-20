class nagios {
    # It takes advantage of puppet's collected resources, which lets other
    # puppet-managed servers configure this nagios monitor with the checks
    # that they need. Docs @ http://reductivelabs.com/trac/puppet/wiki/ExportedResources 
    #
    # Defined here is htpasswd.users, which contains the list of users
    # authorized to access nagios. Edit it in $env/modules/nagios/files/htpasswd.users

  package { [ "nagios3", "nagios-nrpe-plugin"]:
    ensure  => installed,
  }

  service { "nagios3":
    ensure      => running,
    require     => [ Package["nagios3"], Package["nagios-nrpe-plugin"] ],
  }

  file { "/etc/nagios3/conf.d/hosts.cfg":
    ensure  => present,
    mode    => 0644,
    notify  => Service['nagios3'],
  }

  file { "/etc/nagios3/conf.d/services.cfg":
    ensure  => present,
    mode    => 0644,
    notify  => Service['nagios3']
  }

  file { "cgi.cfg" :
    name    => "/etc/nagios3/cgi.cfg",
    content => template("nagios/cgi.cfg.erb"),
    mode    => 644,
    notify  => Service['nagios3']
  }  

  file {"/etc/nagios3/conf.d/generic-service_nagios2.cfg":
    source  => "puppet:///nagios/generic-service_nagios2.cfg",
    require => Package["nagios3"],
    mode    => 0644,
    owner   => "root",
    group   => "root",
    notify  => Exec["reload-nagios"],
  }

  Nagios_host <<| |>> {
    target  => '/etc/nagios3/conf.d/hosts.cfg',
    require => Package['nagios3'],
    notify  => Service['nagios3'],
  }

  Nagios_service <<| |>> {
    target  => "/etc/nagios/conf.d/${::fqdn}.cfg",
    require => Package['nagios3'],
    notify  => Service['nagios3'],
  }

}
