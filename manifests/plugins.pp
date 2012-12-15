class nagios::plugins {
    # nagios::plugins installs a bunch of nagios plugins. It also sets up
    # the /usr/lib/nagios/plugins directory to be synced from the puppetmasters
    # $env/modules/nagios/files/plugins directory. Custom nagios plugins should
    # therefore be put in this directory, and it will propagate to all servers.

    package { [ "nagios-plugins", "nagios-plugins-basic", "nagios-plugins-standard" ]:
        ensure => installed,
    }
    
    file { "/usr/lib/nagios/plugins":
        ensure  => directory,
        source  => "puppet:///nagios/plugins",
        recurse => true,
        ignore  => ".svn",
        require => Package["nagios-plugins"],
    }

    # required for "check_ps.sh"
    package { "bc":
        ensure  => installed,
    }

}