class nagios::basechecks {
    # Base check class. 
    # will be included in base, so that all hosts have this
    # will specify all the definitions of all the checks for all the hosts. 
    # including regular active checks and nrpe checks. 
    # nrpe checks should also be defined in files/nrpe.cfg

    @@nagios_service { "check_ping_$fqdn" :
        host_name           => "$fqdn",
        use                 => "generic-service",
        check_command       => "check_ping!600,20%!1000,50%",
        service_description => "check_ping",
     }

    @@nagios_service { "check_puppetd_lock_$fqdn":
        host_name           => "$fqdn",
        use                 => "generic-service",
        check_command       => "check_nrpe_1arg!check_puppetd_lock",
        service_description => "check_puppetd_lock",
    }

    nagios::nrpe { "check_puppetd_lock":
        command => "check_puppetd_lock"
    }

    @@nagios_service { "check_disk_$fqdn":
        check_command       => "check_nrpe_1arg!check_disk",
        use                 => "generic-service",
        host_name           => $fqdn,
        service_description => "check_disk",
    }

    nagios::nrpe { "check_disk" :
        command => "check_disk -w 20% -c 10% -l"
    }

    @@nagios_service { "check_load_$fqdn":
        check_command       => "check_nrpe_1arg!check_load",
        use                 => "generic-service",
        host_name           => $fqdn,
        service_description => "check_load",
    }

    nagios::nrpe { "check_load" :
        command => "check_load -w8.0,7.5,7.0 -c10,9,8"
    }

    if $operatingsystem == "Debian" {
        @@nagios_service { "check_apt_upgrade_$fqdn":
            check_command       => "check_nrpe_1arg!check_apt_upgrade",
            use                 => "generic-service",
            host_name           => $fqdn,
            service_description => "check_apt_upgrade",
            check_interval      => 60,
            retry_interval      => 60,
        }

        nagios::nrpe { "check_apt_upgrade" :
            command => "check_apt_upgrade --run-apt",
            sudo    => true,
        }
    }

}
