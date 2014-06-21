## TODO

- Given an environement configuration file:
  - `environment_registrar`
    - delete environments when their config file is deleted
    - delete / archive config files if the environment changes
    - add a config file if a new environment appears in etcd?
  - `haproxy_updater` should
    - skip an environment if it's config is incomplete / broken and move on
      with good environments
    - pass backends in with separate service_name and version (like frontends)
    - route traffic to services other than containers
  - `container_registrar`
    - should register just the service name, not `service_name.service`
- Add components to start up containers as required or at least make it
  more obvious that the environment has unmet dependencies.
  - Check that the required containers are in place for the environment 
  - Start the required containers
  - Alternatively, make a little app which says what's missing and route
    requests to it if the environment cannot be setup
- Git hooks for new environment files
- Retire old containers / environments

