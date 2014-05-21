# Docker version 0.11.1

FROM ubuntu:14.04

RUN apt-get update

ADD configure.sh /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/configure.sh"]
