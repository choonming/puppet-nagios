define nagios::nrpe($command, $sudo=false) {
    # nagios::nrpe defines a NRPE command for the nagios agent. For security
    # reasons, NRPE needs all commands that it can execute, to be specified in
    # its config file.
    #
    # Example usage:
    #
    #     nagios::nrpe { "check_something":
    #         command => "check_something -H localhost -x -d -w -q"
    #     }
    #
    #     @@nagios_service { "check_something_$fqdn": 
    #         check_command       => "check_nrpe_1arg!check_something",
    #         use                 => "generic-service",
    #         host_name           => $fqdn,
    #         service_description => "check_something",
    #     } 

    $sudo_command = $sudo ? {
                        true    => "/usr/bin/sudo ",
                        false   => "",
                    }

    file { "/etc/nagios/nrpe.d/$name.cfg":
        content => "command[$name]=$sudo_command/usr/lib/nagios/plugins/$command\n",
        require => Package["nagios-nrpe-server"],
        notify  => Service["nagios-nrpe-server"],
    }

}