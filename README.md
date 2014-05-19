# Mayfly

Mayfly is a tool to setup virtual environments of microservices using docker.
It is intended to simplify the testing of different versions of microservices
working alongside one another before being moved into production.

## TODO

- Configure the apps to forward x-mayfly header with requests
- Dockerize the two apps
- Create a docker container to provide DNS
- Change the flask apps to use the docker DNS
- Configure the host to use the docker DNS
- Setup a loadbalancer to forward requests to the right container
- Setup the load balancer to set the x-mayfly header
- Setup the load balancer to send traffic to the container based on 
  the x-mayfly header
- Load another version of the backend and show that both work

## TODO Later
- Something to configure the load balancer
- Something to launch the right containters
- Something to retire old containers / environments
