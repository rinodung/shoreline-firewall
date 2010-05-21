#! /bin/bash
#     The Shoreline Firewall (Shorewall) Packet Filtering Firewall - V4.4
#
#     This program is under GPL [http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt]
#
#     (c) 2010 - Tom Eastep (teastep@shorewall.net)
#
#       On most distributions, this file should be called /etc/init.d/shorewall.
#
#       Complete documentation is available at http://shorewall.net
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of Version 2 of the GNU General Public License
#       as published by the Free Software Foundation.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# chkconfig: - 09 91
#
### BEGIN INIT INFO
# Provides: shorewall-init
# Default-Start:  2 4 5
# Default-Stop:
# Short-Description: Initialize the firewall at boot time
# Description:       Place the firewall in a safe state at boot time
#                    prior to bringing up the network.  
### END INIT INFO

if [ "$(id -u)" != "0" ]
then
  echo "You must be root to start, stop or restart \"Shorewall \"."
  exit 1
fi

# check if shorewall-init is configured or not
if [ -f "/etc/sysconfig/shorewall-init" ]
then
	. /etc/sysconfig/shorewall-init
	if [ -z "$PRODUCTS" ]
	then
		exit 0
	fi
else
	exit 0
fi

# Initialize the firewall
shorewall_start () {
  local product
  local vardir

  echo -n "Initializing \"Shorewall-based firewalls\": "
  for product in $PRODUCTS; do
      vardir=/var/lib/$product
      [ -f /etc/$product/vardir ] && . /etc/$product/vardir 
      if [ -x ${vardir}/firewall ]; then
	  ${vardir}/firewall stop || exit 1
      fi
  done

  return 0
}

# Clear the firewall
shorewall_stop () {
  local product
  local vardir

  echo -n "Clearing \"Shorewall-based firewalls\": "
  for product in $PRODUCTS; do
      vardir=/var/lib/$PRODUCT
      [ -f /etc/$product/vardir ] && . /etc/$product/vardir 
      if [ -x ${vardir}/firewall ]; then
	  ${vardir}/firewall clear || exit 1
      fi
  done

  return 0
}

case "$1" in
  start)
     shorewall_start
     ;;
  stop)
     shorewall_stop
     ;;
  *)
     echo "Usage: /etc/init.d/shorewall-init {start|stop}"
     exit 1
esac

exit 0
