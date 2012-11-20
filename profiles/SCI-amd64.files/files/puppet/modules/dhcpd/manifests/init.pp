class dhcpd($enabled=yes) {

        file { "/etc/dhcp/dhcpd.conf.puppet":
                owner => "root",
                group => "root",
                mode => 600,
                content => template("dhcpd/dhcpd.conf.erb"),
        }

        file { "/etc/dhcp/dhcpd.conf": }

        file { "/etc/dhcp/.disable-puppet": }

        exec { '/bin/cp -a /etc/dhcp/dhcpd.conf.puppet /etc/dhcp/dhcpd.conf; /bin/sed -i "s/changeme/$(/bin/cat /etc/bind/keys|/bin/grep secret|/usr/bin/cut -f6 -d\' \')/" /etc/dhcp/dhcpd.conf; touch /etc/dhcp/.disable-puppet':
                creates =>  [ "/etc/dhcp/.disable-puppet", "/etc/dhcp/dhcpd.conf", ],
        }

	exec { "/usr/sbin/dpkg-divert --divert /etc/dhcp/dhcpd.conf --rename /etc/dhcp/dhcpd.conf.dist":
                require =>  File["/etc/dhcp/dhcpd.conf"],
        }

if $enabled==yes {
        package {isc-dhcp-server:
		ensure=> installed,
		require =>  File["/etc/dhcp/.disable-puppet"],
	}

        exec { "/etc/init.d/isc-dhcp-server restart":
                subscribe => File[ "/etc/dhcp/.disable-puppet" ],
                refreshonly => true,
                require => Package['isc-dhcp-server'],
        }
}
else {
        package {isc-dhcp-server:
                ensure=> absent,
        }
}

}
