# NFS Ganesha

A user mode nfs server implemented in a container.
Supports serving NFS (v3, v4).

Currently generates a config for just serving a local path over nfs.
However supplying `GANESHA_CONFIGFILE` would allow ganesha
to be pointed to a bind mounted config file for other FASLs/more advanced configuration.

## Versions

* ganesha: 2.8.2

## Environment Variables

* `GANESHA_LOGFILE`: log file location
* `GANESHA_PID`: log file location
* `GANESHA_CONFIGFILE`: location of ganesha.conf
* `GANESHA_OPTIONS`: command line options to pass to ganesha
* `GANESHA_EPOCH`: ganesha epoch value
* `GANESHA_EXPORT_ID`: ganesha unique export id
* `GANESHA_EXPORT`: export location
* `GANESHA_NFS_PROTOCOLS`: nfs protocols to support
* `GANESHA_TRANSPORTS`: nfs transports to support
* `STARTUP_SCRIPT`: location of a shell script to execute on start

### Environment Placement in Config File

````
EXPORT
{
		# Export Id (mandatory, each EXPORT must have a unique Export_Id)
		Export_Id = ${GANESHA_EXPORT_ID};

		# Exported path (mandatory)
		Path = ${GANESHA_EXPORT};

		# Pseudo Path (for NFS v4)
		Pseudo = /;

		# Access control options
		Access_Type = RW;
		Squash = No_Root_Squash;
		Root_Access = "${GANESHA_ROOT_ACCESS}";
		Access = "${GANESHA_ACCESS}";

		# NFS protocol options
		Transports = "${GANESHA_TRANSPORTS}";
		Protocols = "${GANESHA_NFS_PROTOCOLS}";

		SecType = "sys";

		# Exporting FSAL
		FSAL {
			Name = VFS;
		}
}
````

## Usage

```bash
docker run \
	-d \
	--privileged \
	--name nfs-ganesha-server \
	-v $(mktemp -d):/export:rw \
	rtfpessoa/nfs-ganesha:dev
```

## Credits

* [mitcdh/docker-nfs-ganesha](https://github.com/mitcdh/docker-nfs-ganesha)
