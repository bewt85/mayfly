# Mayfly

Mayfly is a tool to setup virtual environments of microservices using docker.
It is intended to simplify the testing of different versions of microservices
working alongside one another before being moved into production.

## TODO

- Create two versions of the frontend and backend 
  - Create templates so that old and new versions look different
- Load haproxy.cfg to serve different combinations of the apps
- When a container starts up an ambasador should register it as a new backend
  in HAProxy
- Given an environement configuration file:
  - Create frontend configuration for the environement
  - Check that backend config is in place
  - Start the required containers
  - [ build the required containers ]

## TODO Later

- Multi-host / Digital Ocean
  - Create simple ansible script to setup and secure host machine
  - Tunnel HTTP over SSH (poor man's VPN)
- Git hooks for new environment files
- What about databases / things that can't have a x-mayfly header applied?
- Retire old containers / environments

# Tools to look at
- confd + etcd / consul to create new config
- fleet to deploy across a couple of machines
- fig for deploying on one machine if fleet is overkill
