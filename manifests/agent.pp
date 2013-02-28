class nagios::agent (
  $nrpe_port = '5666',
  $server_ip
  ) {

    # nagios::agent defines a nagios agent (i.e. the server that is being
    # monitored). It must be included in every server that needs to be
    # monitored, ideally as part of the base configuration. This is because
    # this class defines the Nagios_host resource, which the services checks
    # depend on.
    #
    # nagios::agent also installs NRPE, which is the nagios remote execution
    # plugin. This lets nagios run arbitrary commands on the monitored server
    # for checks. Docs @ http://nagios.sourceforge.net/docs/nrpe/NRPE.pdf
    #
    # TODO: add firewall rules [Done for 5666/nrpe - alvin]

    include nagios::plugins
    include nagios::basechecks

    package { "nagios-nrpe-server":
        ensure => installed,
    }

    file { "/etc/nagios/nrpe_local.cfg":
        ensure  => absent,
    }

    file { "/etc/nagios/nrpe.cfg":
        content => template('nagios/nrpe.cfg.erb'),
        require => Package["nagios-nrpe-server"],
        mode    => 0644 , 
        owner   => "root" ,
        group   => "root" ,
    }

    # custom written commands not available from /etc/nagios-plugins/config/
    file { "/etc/nagios-plugins/config/custom_commands.cfg":
        source  => "puppet:///modules/nagios/custom_commands.cfg",
        require => Package["nagios-nrpe-server"],
        mode    => 0644 ,
        owner   => "root" ,
        group   => "root" ,
    }

    file { "/etc/nagios/nrpe.d":
        ensure  => directory,
        require => Package["nagios-nrpe-server"],
    }

    service { "nagios-nrpe-server":
        ensure      => running,
        require     => File["/etc/nagios/nrpe.cfg"],
        subscribe   => File["/etc/nagios/nrpe.cfg"],
        status      => "/usr/bin/test -d /proc/`cat /var/run/nrpe.pid`"
    }

    @@nagios_host { $fqdn:
        ensure      => present,
        address     => $fqdn,
        use         => "generic-host",
    }

}
