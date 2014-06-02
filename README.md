# Mayfly

Mayfly is a tool to setup virtual environments of microservices using docker.
It is intended to simplify the testing of different versions of microservices
working alongside one another before being moved into production.

## TODO

- Given an environement configuration file:
  - Given environment etcd config, update the haproxy config
  - frontend\_registrar
    - [ delete environments when their config file is deleted ]
    - [ delete / archive config files if the environment changes ]
    - [ add a config file if a new environment appears in etcd? ]
  - configure\_haproxy should
    - skip an environment if it's config is incomplete / broken and move on
      with good environments
    - deduplicate stuff in environment config
    - pass backends in with separate service\_name and versions (like frontends)
    - route traffic to service other than containers
    - [ think about having request which are not on port 80 ]
    - [ play nicely with existing haproxy config ]
  - backend\_registrar
    - should register just the service name, not service\_name.service
- When / why are the registrars falling over?
- Given some etcd config
  - Check that the backends are inplace for the frontends 
  - Start the required containers
  - [ build the required containers ]

## TODO Later

- Multi-host / Digital Ocean
  - Create simple ansible script to setup and secure host machine
  - Tunnel HTTP over SSH (poor man's VPN)
- Git hooks for new environment files
- What about databases / things that can't have a x-mayfly header applied?
- Retire old containers / environments
- Tidy up / document / split into different repos

# Tools to look at

- fleet to deploy across a couple of machines
- fig for deploying on one machine if fleet is overkill
