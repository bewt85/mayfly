# Docker version 0.11.1

FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y wget git golang vim

RUN wget https://github.com/coreos/etcdctl/archive/v0.4.1.tar.gz && tar -xzf v0.4.1.tar.gz
RUN cd etcdctl-0.4.1 && ./build

ENV PATH /etcdctl-0.4.1/bin:$PATH
ADD run.sh /run.sh
ADD link.sh /link.sh

ENTRYPOINT ["/link.sh"]
