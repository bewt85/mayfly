# Mayfly

Mayfly is a tool to setup virtual environments of microservices using docker.
It is intended to simplify the testing of different versions of microservices
working alongside one another before being moved into production.

## TODO

- Given an environement configuration file:
  - Given environment etcd config, update the haproxy config
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
- Tidy up / split into different repos

# Tools to look at

- fleet to deploy across a couple of machines
- fig for deploying on one machine if fleet is overkill
