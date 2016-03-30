#!/bin/sh
#
# /etc/init.d/wildfly -- startup script for WildFly
#
# Written by Hexaforce
#
### BEGIN INIT INFO
# Provides:             wildfly
# Required-Start:       none
# Required-Stop:        none
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Description:          WildFly Application Server startup/shutdown script
### END INIT INFO

export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
export WILDFLY_HOME=/opt/wildfly-10.0.0.CR2

if [ ! -f "$JAVA_HOME/bin/jps" ]; then
	echo "JavaSDK is not installed in \"$JAVA_HOME\""
	exit 1
fi

if [ ! -f "$WILDFLY_HOME/jboss-modules.jar" ]; then
	echo "WildFly is not installed in \"$WILDFLY_HOME\""
	exit 1
fi

export LAUNCH_JBOSS_IN_BACKGROUND=1

ALLOW_SERVICE_PORT="-b 0.0.0.0"
ALLOW_MANAGE_PORT="-bmanagement=0.0.0.0"
CONFIG_STANDALONE_XML="-c standalone.xml"

MANAGED_PID="$WILDFLY_HOME/bin/managed.pid"
WILDFLY_PID="$WILDFLY_HOME/bin/wildfly.pid"

start() {
	$WILDFLY_HOME/bin/standalone.sh $ALLOW_SERVICE_PORT $ALLOW_MANAGE_PORT $CONFIG_STANDALONE_XML &
	sleep 6
	check_pid $MANAGED_PID
	echo "WildFly was start up. pid:"`cat ${MANAGED_PID}`
}

stop() {
	kill -9 `cat ${MANAGED_PID}`
	echo "WildFly was stopped. pid:"`cat ${MANAGED_PID}`
	rm -f $MANAGED_PID $WILDFLY_PID
	sleep 1
}

status() {

	check_pid $WILDFLY_PID
	pid=`cat ${WILDFLY_PID}`

	if [ -e $MANAGED_PID ]; then
		m_pid=`cat ${MANAGED_PID}`
		if [ "$pid" = "$m_pid" ]; then
			echo "WildFly is running."
			return 0
		else
			echo "Ambiguous status. Please restarted after a pid file is deleted.　> $MANAGED_PID"
			return 1
		fi
	else
		if [ -n "$pid" ]; then
			echo "WildFly is running. It has been started by other processes. pid:"$pid
			return 2
		else
			echo "WildFly is not running."
			return 3
		fi
	fi

}

check_pid() {
	$JAVA_HOME/bin/jps | grep jboss-modules.jar | sed -e 's/ jboss-modules.jar//g' > $1
	chmod 755 $1
}

case "$1" in
	start)
		status ; [ $? -eq 3 ] && start
	;;
	stop)
		status ; [ $? -eq 0 ] && stop
	;;
	restart)
		status ; [ $? -eq 0 ] && stop
		status ; [ $? -eq 3 ] && start
	;;
	status)
		status
	;;
	*)
		echo "Usage: $0 {start|stop|restart|status}"
		exit 1
	;;
esac
