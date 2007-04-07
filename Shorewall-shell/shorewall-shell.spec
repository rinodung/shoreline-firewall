%define name shorewall-shell
%define version 3.9.1
%define release 1
%define prefix /usr

Summary: Shoreline Firewall is an iptables-based firewall for Linux systems.
Name: %{name}
Version: %{version}
Release: %{release}
Prefix: %{prefix}
License: GPL
Packager: Tom Eastep <teastep@shorewall.net>
Group: Networking/Utilities
Source: %{name}-%{version}.tgz
URL: http://www.shorewall.net/
BuildArch: noarch
BuildRoot: %{_tmppath}/%{name}-%{version}-root
Requires: iptables iproute

%description

The Shoreline Firewall, more commonly known as "Shorewall", is a Netfilter
(iptables) based firewall that can be used on a dedicated firewall system,
a multi-function gateway/ router/server or on a standalone GNU/Linux system.

%prep

%setup

%build

%install
export PREFIX=$RPM_BUILD_ROOT ; \
export OWNER=`id -n -u` ; \
export GROUP=`id -n -g` ;\
./install.sh -n

%clean
rm -rf $RPM_BUILD_ROOT

%post

if [ $1 -eq 1 ]; then
	if [ -x /sbin/insserv ]; then
		/sbin/insserv /etc/rc.d/shorewall
	elif [ -x /sbin/chkconfig ]; then
		/sbin/chkconfig --add shorewall;
	fi
fi

%preun

if [ $1 = 0 ]; then
	if [ -x /sbin/insserv ]; then
		/sbin/insserv -r /etc/init.d/shorewall
	elif [ -x /sbin/chkconfig ]; then
		/sbin/chkconfig --del shorewall
	fi

	rm -f /etc/shorewall/startup_disabled

fi

%files
%defattr(0644,root,root,0755)
%attr(0755,root,root) %dir /usr/share/shorewall-shell

%attr(0555,root,root) /usr/share/shorewall/compiler
%attr(0444,root,root) /usr/share/shorewall/lib.accounting
%attr(0444,root,root) /usr/share/shorewall/lib.actions
%attr(0444,root,root) /usr/share/shorewall/lib.dynamiczones
%attr(0444,root,root) /usr/share/shorewall/lib.maclist
%attr(0444,root,root) /usr/share/shorewall/lib.nat
%attr(0444,root,root) /usr/share/shorewall/lib.providers
%attr(0444,root,root) /usr/share/shorewall/lib.proxyarp
%attr(0444,root,root) /usr/share/shorewall/lib.tc
%attr(0444,root,root) /usr/share/shorewall/lib.tcrules
%attr(0444,root,root) /usr/share/shorewall/lib.tunnels
%attr(0644,root,root) /usr/share/shorewall/prog.footer
%attr(0644,root,root) /usr/share/shorewall/prog.header

%doc COPYING INSTALL 

%changelog
* Tue Apr 03 2007 Tom Eastep tom@shorewall.net
- Initial Version

