## Tools volume

This images creates a volume ${SERVICE_VOLUME} and permits share tools with the services, avoiding coupling service with configuration.

That volume has the following structure:

```
|- /opt/tools 		# SERVICE_VOLUME base path
|-|- confd 			# Confd directory
|-|-|- etc
|-|-|-|- templates
|-|-|-|- conf.d
|-|-|- bin
|-|- monit/conf.d 	# Monit start script directory
|-|- scripts 		# Scripts directory
```

## Volume owner

The entrypoint set correct owner to ${SERVICE_VOLUME} volume. You must provide UID and GID for your service, overriding env variables:

- SERVICE_UID=${SERVICE_UID:-"0"} 
- SERVICE_GID=${SERVICE_GID:-"0"}
- SERVICE_VOLUME=${SERVICE_VOLUME:-"/opt/tools"}
- SERVICE_ARCHIVE=${SERVICE_ARCHIVE:-"/opt/tools.tgz"}
- KEEP_ALIVE=${KEEP_ALIVE:-"0"} 	# Set to "1" to run in kubernetes as multicontainer pod. To keep alive.


## Config management

This image compiles and intall confd under ${SERVICE_VOLUME}/confd, to make it super simple to get dinamic configuration for your service. 

## Usage

To use this image include `FROM robtimmer/alpine-tools` at the top of your `Dockerfile`, and add whaever tool you need your services under /opt/tools.

Starting from `robtimmer/alpine-tools` provides you with the ability to easily get dinamic configuration using confd. confd will also keep running checking for config changes, restarting your service.

This image has to be started once as a sidekick of your service (based in alpine-monit), exporting a ${SERVICE_VOLUME} volume to it. It adds monit conf.d to start confd with a default parameters, that you can overwrite with environment variables.

[confd]: http://www.confd.io/
[jq]: https://github.com/stedolan/jq
