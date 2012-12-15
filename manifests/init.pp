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

    exec { "reload-nagios":
        command     => "/etc/init.d/nagios3 reload",
        require     => Service["nagios3"],
        refreshonly => true,
    }

    exec { "reload-httpd":
        command     => "/etc/init.d/apache2 reload",
        refreshonly => true,
    }

    file { "/etc/nagios3/conf.d/hosts.cfg":
        ensure  => present,
        mode    => 0644,
    }

    file { "/etc/nagios3/conf.d/services.cfg":
        ensure  => present,
        mode    => 0644,
    }

    firewall { '101 httpd':
      chain   => 'INPUT',
      action  => 'accept',
      proto   => 'tcp',
      dport   => '80',
    }

    file { "cgi.cfg" :
        name    => "/etc/nagios3/cgi.cfg",
        content => template("nagios/cgi.cfg.erb"),
        mode    => 644,
        notify  => Exec["reload-httpd"]
    }  

    nagios_command { 'check_http_alt':
      command_line  => "/usr/lib/nagios/plugins/check_http -H '$HOSTADDRESS$' -p '$ARG1$'  -u '$ARG2$'  -e 'HTTP/1.1 200 OK'",
      ensure  => 'present',
    }

    nagios_contact { 'choonming':
      ensure  => present,
      alias   => 'CM',
      email   => 'choonming@olindata.com',
      host_notification_commands    => 'notify-service-by-email',
      service_notification_commands => 'notify-service-by-email',
      host_notification_period    => '24x7',
      service_notification_period => '24x7',
      host_notification_options     => 'd,r',
      service_notification_options  => 'w,c,u,r',
	  target  => '/etc/nagios3/conf.d/nagios_contacts.cfg',
    }

    nagios_contactgroup { 'admins':
      ensure  => 'present',
      alias   => 'admin',
      members => 'choonming',
	  target  => '/etc/nagios3/conf.d/nagios_contactgroup.cfg',
    }

    file {"/etc/nagios3/conf.d/generic-service_nagios2.cfg":
        source  => "puppet:///nagios/generic-service_nagios2.cfg",
        require => Package["nagios3"],
        mode    => 0644,
        owner   => "root",
        group   => "root",
        notify  => Exec["reload-nagios"],
    }

}