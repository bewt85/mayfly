# Mayfly

Mayfly is a tool to setup virtual environments of microservices using docker.
It is intended to simplify the testing of different versions of microservices
working alongside one another before being moved into production.

## Demo

You can run an interactive demo by running:

```
sudo ./demo/01.sh
```

## Examples

To build the required containers locally, run:

```
sudo ./scripts/build.sh
```

TODO: Create a simple way to build a few versions of the apps

To start the containers, run:

```
sudo ./scripts/run.sh
```

TODO: Something about DNS

Visit www.example.com - you should get a 503

To get an example config file:

```
cat frontend_registrar/example_config/prod-example.yaml
```

Update HAProxy by copying this file into:

```
sudo docker run -i -t --rm --volumes-from frontend_registrar ubuntu vi /etc/mayfly/environments/prod.yaml
```

Visit www.example.com - you should simple page

Change the version of the frontend and / or backend from 0.0.1 to 0.0.2:

```
sudo docker run -i -t --rm --volumes-from frontend_registrar ubuntu vi /etc/mayfly/environments/prod.yaml
```

Visit www.example.com - the page should have changed

To kill all the running containers on the host, run:

```
sudo ./scripts/kill --rm
```

## Components

### hproxy

Runs HAProxy.  HAProxy is reloaded whenever the config file 
`/etc/haproxy/haproxy.cfg` changes on disk.

### configure\_haproxy

Watches etcd for changes to keys starting `/mayfly` and updates 
`/etc/haproxy/haproxy.cfg`.  The config makes use of the `x-mayfly` header to 
route internal traffic to the right version of the app depending on the 
environment being used.  These headers are added to external traffic and 
containers should forward this on with any internal requests.

This container should be run with `/etc/haproxy/` mounted from an haproxy 
container.

### frontend\_registrar

Watches the `/etc/mayfly/environments/` directory for changes.  If a `*.yaml` 
file is added, it parses the file and updates etcd so that `configure\_haproxy
can make required updates.

### service\_registrar

Runs a script which takes the name and version of a service container as 
arguments.  These are used to advertise the service to configure\_haproxy 
including the host and port to access the service.

The etcd keys set by this container have a short ttl; if this container stops
configure\_haproxy will believe that the backend service is no longer 
available.  This can be used with a service like `fleet` by binding this 
container to a running service container.

### service containers

I've created two simple services 'frontend' and 'backend' using flask.  I built
them in 0.0.1 and 0.0.2 versions.

### dnsmasq

Provides DNS to containers as required.  Like haproxy it watches a file 
`/etc/dnsmasq/hosts` for changes and reloads if any are found.

### configure\_dns

This container runs a script this updates the file used by dnsmasq.  It should
therefore be run with `/etc/dnsmasq/` mounted from dnsmasq

## TODO

- Given an environement configuration file:
  - frontend\_registrar
    - delete environments when their config file is deleted
    - delete / archive config files if the environment changes
    - add a config file if a new environment appears in etcd?
  - configure\_haproxy should
    - skip an environment if it's config is incomplete / broken and move on
      with good environments
    - pass backends in with separate service\_name and versions (like frontends)
    - route traffic to services other than containers
  - backend\_registrar
    - should register just the service name, not service\_name.service
- When / why are the registrars falling over?
- Given some etcd config
  - Check that the backends are inplace for the frontends 
  - Start the required containers
- Git hooks for new environment files
- Retire old containers / environments
