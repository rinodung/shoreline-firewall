#!/bin/sh
### BEGIN INIT INFO
# Provides:          shorewall6
# Required-Start:    $network
# Required-Stop:     $network
# Default-Start:     S
# Default-Stop:      0 6
# Short-Description: Configure the firewall at boot time
# Description:       Configure the firewall according to the rules specified in
#                    /etc/shorewall6
### END INIT INFO



SRWL=/sbin/shorewall6
SRWL_OPTS="-tvv"
WAIT_FOR_IFUP=/usr/share/shorewall/wait4ifup
# Note, set INITLOG to /dev/null if you do not want to
# keep logs of the firewall (not recommended)
INITLOG=/var/log/shorewall-init.log

test -x $SRWL || exit 0
test -x $WAIT_FOR_IFUP || exit 0
test -n $INITLOG || {
	echo "INITLOG cannot be empty, please configure $0" ; 
	exit 1;
}

if [ "$(id -u)" != "0" ]
then
  echo "You must be root to start, stop or restart \"Shorewall6 firewall\"."
  exit 1
fi

echo_notdone () {

  if [ "$INITLOG" = "/dev/null" ] ; then 
	  echo "not done."
  else 
	  echo "not done (check $INITLOG)."
  fi

}

not_configured () {
	echo "#### WARNING ####"
	echo "The firewall won't be started/stopped unless it is configured"
	if [ "$1" != "stop" ]
	then
		echo ""
		echo "Please read about Debian specific customization in"
		echo "/usr/share/doc/shorewall6/README.Debian.gz."
	fi
	echo "#################"
	exit 0
}

# check if shorewall is configured or not
if [ -f "/etc/default/shorewall6" ]
then
	. /etc/default/shorewall
	SRWL_OPTS="$SRWL_OPTS $OPTIONS"
	if [ "$startup" != "1" ]
	then
		not_configured
	fi
else
	not_configured
fi

# wait for an unconfigured interface 
wait_for_pppd () {
	if [ "$wait_interface" != "" ]
	then
		for i in $wait_interface
		do
			$WAIT_FOR_IFUP $i 90
		done
	fi
}

# start the firewall
shorewall6_start () {
  echo -n "Starting \"Shorewall6 firewall\": "
  wait_for_pppd
  $SRWL $SRWL_OPTS start >> $INITLOG 2>&1 && echo "done." || echo_notdone
  return 0
}

# stop the firewall
shorewall6_stop () {
  echo -n "Stopping \"Shorewall firewall\": "
  $SRWL $SRWL_OPTS clear >> $INITLOG 2>&1 && echo "done." || echo_notdone
  return 0
}

# restart the firewall
shorewall6_restart () {
  echo -n "Restarting \"Shorewall6 firewall\": "
  $SRWL $SRWL_OPTS restart >> $INITLOG 2>&1 && echo "done." || echo_notdone
  return 0
}

# refresh the firewall
shorewall6_refresh () {
  echo -n "Refreshing \"Shorewall6 firewall\": "
  $SRWL $SRWL_OPTS refresh >> $INITLOG 2>&1 && echo "done." || echo_notdone
  return 0
}

case "$1" in
  start)
     shorewall6_start
     ;;
  stop)
     shorewall6_stop
     ;;
  refresh)
     shorewall6_refresh
  	  ;;
  force-reload|restart)
     shorewall6_restart
     ;;
  *)
     echo "Usage: /etc/init.d/shorewall6 {start|stop|refresh|restart|force-reload}"
     exit 1
esac

exit 0
