## TODO

- Check demo still works
- Use DNS rather than headers to route requests
- Start containers as specified in the environment config
  - specify better environment config
  - update the etcd representaion of the config
  - create / update a container to start other containers
- Do some actual health checking on backends and create a host canary container
- Replace containers with slugs
  - Turn services into flynn style slugs
  - Create a WebDav container
  - Put some slugs in it
- Add basic runtime config to containers, manage this at deploy time / as part
  of the environment
- Create a GUI to control environments
  - list environments
  - create environments
  - delete environments
  - check that the required containers are in place for the environment 
  - `haproxy_updater` should redirect to a page specifying problems with an environment 
  - start containers on manually specified hosts
  - export / import / restore evironment config
