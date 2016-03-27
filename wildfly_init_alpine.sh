#!/bin/sh
#
# /etc/init.d/wildfly -- startup script for WildFly
#
# Written by Hexaforce
#
### BEGIN INIT INFO
# Provides:             wildfly
# Required-Start:       $java_home $wildfly_home
# Required-Stop:        $java_home $wildfly_home
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Description:          WildFly Application Server startup/shutdown script
### END INIT INFO

#export WILDFLY_HOME=/root/wildfly-10.0.0.Final

if [ -n "$JAVA_HOME" ]; then
	export JAVA_HOME
else
	export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk
fi

if [ -z "$JAVA" ]; then
	if [ -n "$JAVA_HOME" ]; then
		JAVA="$JAVA_HOME/bin/java"
	else
		JAVA="java"
	fi
fi

if [ -z "$WILDFLY_HOME" ]; then
	WILDFLY_HOME="/opt/wildfly"
fi
export WILDFLY_HOME

if [ ! -f "$WILDFLY_HOME/jboss-modules.jar" ]; then
	echo "WildFly is not installed in \"$WILDFLY_HOME\""
	exit 1
fi

start() {
	export LAUNCH_JBOSS_IN_BACKGROUND=1
	$WILDFLY_HOME/bin/standalone.sh -b 0.0.0.0 &
	sleep 3
	jboss_modules pid_wildfly.pid
	pid_wildfly=`cat ${WILDFLY_HOME}/bin/pid_wildfly.pid`
	echo "WildFly was start up. (pid:$pid_wildfly)"
}

stop() {
	pid_wildfly=`cat ${WILDFLY_HOME}/bin/pid_wildfly.pid`
	kill -9 $pid_wildfly
	rm -f $WILDFLY_HOME/bin/pid_wildfly.pid
	echo "WildFly was stopped."
}

status() {

	jboss_modules jps_wildfly.pid
	jps_wildfly=`cat ${WILDFLY_HOME}/bin/jps_wildfly.pid`

	if [ -e $WILDFLY_HOME/bin/pid_wildfly.pid ]; then
		pid_wildfly=`cat ${WILDFLY_HOME}/bin/pid_wildfly.pid`
	else
		if [ -n "$jps_wildfly" ]; then
			echo "WildFly is running. It has been started by other processes. (pid:$jps_wildfly)"
			return 1
		else
			echo "WildFly is not running."
			return 2
		fi
	fi

	if [ "$jps_wildfly" = "$pid_wildfly" ]; then
		echo "WildFly is already running."
		return 0
	else
		echo "Ambiguous status. Please restarted after a [pid_wildfly.pid] file is deleted.　> $WILDFLY_HOME/bin/pid_wildfly.pid"
		return 3
	fi

}

jboss_modules() {
	$JAVA_HOME/bin/jps | grep jboss-modules.jar | sed -e 's/ jboss-modules.jar//g' > $WILDFLY_HOME/bin/$1
	chmod 777 $WILDFLY_HOME/bin/$1
}

case "$1" in
	start)
		status
		ret=$?
		if [ $ret -eq 2 ]; then
			start
		fi
		exit 0
	;;
	stop)
		status
		ret=$?
		if [ $ret -eq 0 ]; then
			stop
		fi
		exit 0
	;;
	restart)
		status
		ret=$?
		if [ $ret -eq 0 ]; then
			stop
		fi
		status
		ret=$?
		if [ $ret -eq 2 ]; then
			start
		fi
		exit 0
	;;
	status)
		status
		exit 0
	;;
	*)
		echo "Usage: $0 {start|stop|restart|status}"
		exit 1
	;;
esac
