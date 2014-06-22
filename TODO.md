## TODO

- Replace individual mayfly-container-registrars with something that talks to docker
- The new registrar should register the service name and version, not 
  `service_name.service`
  - Make corresponding update to haproxy
- Replace containers with slugs
  - Turn services into flynn style slugs
  - Create a WebDav container
  - Put some slugs in it
- Add basic runtime config to containers, manage this at deploy time / as part
  of the environment
- Use DNS rather than headers to route requests
- Do some actual health checking on backends and create a host canary container
- Create a GUI to control environments
  - list environments
  - create environments
  - delete environments
  - check that the required containers are in place for the environment 
  - `haproxy_updater` should redirect to a page specifying problems with an environment 
  - start containers on manually specified hosts
  - export / import / restore evironment config