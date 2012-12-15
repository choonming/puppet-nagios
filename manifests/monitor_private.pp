class nagios::monitor_private {

    if ($environment == "production" ) {
        Nagios_host <<| tag == "localhost" |>> {
            target  => "/etc/nagios3/conf.d/hosts.cfg",
            require => Package["nagios3"],
            notify  => Exec["reload-nagios"],
        }

        Nagios_host <<| tag == "prod.localhost" |>> {
            target  => "/etc/nagios3/conf.d/hosts.cfg",
            require => Package["nagios3"],
            notify  => Exec["reload-nagios"],
        }

        Nagios_service <<| tag == "localhost" |>> {
            target  => "/etc/nagios3/conf.d/services.cfg",
            require => Package["nagios3"],
            notify  => Exec["reload-nagios"],
        }

        Nagios_service <<| tag == "prod.localhost" |>> {
            target  => "/etc/nagios3/conf.d/services.cfg",
            require => Package["nagios3"],
            notify  => Exec["reload-nagios"],
        }

    }

    else {
        Nagios_host <<| tag == "dev.localhost" |>> {
            target  => "/etc/nagios3/conf.d/hosts.cfg",
            require => Package["nagios3"],
            notify  => Exec["reload-nagios"],
        }

        Nagios_service <<| tag == "dev.localhost" |>> {
            target  => "/etc/nagios3/conf.d/services.cfg",
            require => Package["nagios3"],
            notify  => Exec["reload-nagios"],
        }
    }
}