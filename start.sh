#!/bin/bash
set -e

# Options for starting Ganesha
: ${GANESHA_LOGFILE:="/dev/stdout"}
: ${GANESHA_CONFIGFILE:="/etc/ganesha/ganesha.conf"}
: ${GANESHA_OPTIONS:="-N NIV_EVENT"} # NIV_DEBUG
: ${GANESHA_EPOCH:=""}
: ${GANESHA_EXPORT_ID:="77"}
: ${GANESHA_EXPORT:="/export"}
# : ${GANESHA_ACCESS:="*"}
# : ${GANESHA_ROOT_ACCESS:="*"}
: ${GANESHA_NFS_PROTOCOLS:="3,4"}
: ${GANESHA_TRANSPORTS:="UDP,TCP"}

function bootstrap_config {
	echo "Bootstrapping Ganesha NFS config"
	mkdir -p `dirname ${GANESHA_CONFIGFILE}`
	cat <<END >${GANESHA_CONFIGFILE}

# Config taken from: https://github.com/kubernetes-incubator/external-storage/blob/master/nfs/pkg/server/server.go
EXPORT
{
	# Export Id (mandatory, each EXPORT must have a unique Export_Id)
	Export_Id = ${GANESHA_EXPORT_ID};
	# Exported path (mandatory)
	Path = ${GANESHA_EXPORT};
	# Pseudo Path (required for NFS v4)
	Pseudo = ${GANESHA_EXPORT};
	# Required for access (default is None)
	# Could use CLIENT blocks instead
	Access_Type = RW;
	# Exporting FSAL
	FSAL {
		Name = VFS;
	}
}

NFS_Core_Param
{
	MNT_Port = 20048;
	fsid_device = true;
}
NFSV4
{
	Grace_Period = 90;
}

END
}

function bootstrap_export {
	if [ ! -f ${GANESHA_EXPORT} ]; then
		mkdir -p "${GANESHA_EXPORT}"
  	fi
}

function init {
	echo "Starting rpcbind"
	/usr/sbin/rpcbind -w
	sleep 2
	/usr/sbin/rpc.statd

	sleep 2

	dbus-daemon --system
	sleep 2
	#rpcbind || return 0
	#rpc.statd -L || return 0
	#rpc.idmapd || return 0
	#sleep 1
}

# function init_dbus {
# 	echo "Starting dbus"
# 	rm -f /var/run/dbus/system_bus_socket
# 	rm -f /var/run/dbus/pid
# 	dbus-uuidgen --ensure
# 	dbus-daemon --system --fork
# 	sleep 1
# }

function startup_script {
	mkdir -p /usr/local/var/lib/nfs/ganesha

	if [ -f "${STARTUP_SCRIPT}" ]; then
  		/bin/sh ${STARTUP_SCRIPT}
	fi
}

bootstrap_config
bootstrap_export
startup_script

init


echo "Starting Ganesha NFS"
# Do we need this?
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib
exec ganesha.nfsd -F -L ${GANESHA_LOGFILE} -f ${GANESHA_CONFIGFILE} ${GANESHA_ADDITIONAL_OPTIONS}
