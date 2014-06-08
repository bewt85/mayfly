# Mayfly

Many projects use a number of separate environments as part of their deployment 
pipeline.  These might include a dev environment in which the latest version of the
software is automatically deployed; a qa environment for testing a specific 
configuration of components; a staging environment which is only "one change away from
production" (i.e. holding what you next plan on deploying); and a production 
environment.

Sometimes however, developers might want to change a couple of components at once and
test them without having to lock up the qa environment from being used by everyone else
or user researchers might want to test a specific configuration.

Mayfly is designed to setup short lived virtual environments to meet these needs.  By 
pushing a yaml config file to a repo you can quickly setup versions of services which, 
for example, are accessible from "www-temp-1.example.com" without disrupting other users 
of the qa environment.

Mayfly is a project I knocked together while taking a break which demonstrates this 
concept.  I wouldn't use it in a production environment or indeed a development 
environment before making a few more changes.  Realistically I'm unlikely to do this
unless we actually deploy something like this at work.  Forking  is very welcome though
if you think this is a good concept.

## Demo

Get the submodules:

```
git submodule init
git submodule update
```

You can create your own versions of the required containers by setting the following 
environment variable to your docker index username (if you don't it uses mine) and 
running this bash script:

```
export DOCKER_ACCOUNT_NAME=<your_name>
sudo ./scripts/build.sh
```

Add a few DNS entries to your `/etc/hosts`:

```
sudo sh -c 'echo "127.0.0.1 www.example.com www-dev.example.com www-qa.example.com" >> /etc/hosts'
```

You can then run the interactive demo:

```
sudo -E ./demo/start.sh
```

## Components

### [hproxy](https://github.com/bewt85/docker-haproxy)
Runs HAProxy.  HAProxy is reloaded whenever the config file 
`/etc/haproxy/haproxy.cfg` changes on disk.

### [haproxy_updater](https://github.com/bewt85/mayfly-haproxy-updater)

Watches etcd for changes to keys starting `/mayfly` and updates 
`/etc/haproxy/haproxy.cfg`.  The config makes use of the `x-mayfly` header to 
route internal traffic to the right version of the app depending on the 
environment being used.  These headers are added to external traffic and 
containers should forward this on with any internal requests.

This container should be run with `/etc/haproxy/` mounted from an haproxy 
container.

### [environment_registrar](https://github.com/bewt85/mayfly-environment-registrar)

Watches the `/etc/mayfly/environments/` directory for changes.  If a `*.yaml` 
file is added, it parses the file and updates etcd so that `haproxy_updater`
can make required updates.

### [container_registrar](https://github.com/bewt85/mayfly-container-registrar)

Runs a script which takes the name and version of a service container as 
arguments.  These are used to advertise the service to `haproxy_updater` 
including the host and port to access the service.

The etcd keys set by this container have a short ttl; if this container stops
`haproxy_updater` will believe that the backend service is no longer 
available.  This can be used with a service like `fleet` by binding this 
container to a running service container.

### demo containers

I've created two simple services [frontend](https://github.com/bewt85/example-frontend) 
and [backend](https://github.com/bewt85/example-backend) using flask.  I built them 
in 0.0.1 and 0.0.2 versions.

### [dnsmasq](https://github.com/bewt85/docker-dnsmasq)

Provides DNS to containers as required.  Like `haproxy` it watches a file 
`/etc/dnsmasq/hosts` for changes and reloads if any are found.

### [dns_updater](https://github.com/bewt85/mayfly-dnsmasq-updater)

This container runs a script this updates the file used by `dnsmasq`.  It should
therefore be run with `/etc/dnsmasq/` mounted from `dnsmasq`.

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
