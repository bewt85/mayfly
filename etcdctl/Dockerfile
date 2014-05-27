# Docker version 0.11.1

FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y wget golang 

RUN wget https://github.com/coreos/etcdctl/archive/v0.4.1.tar.gz && tar -xzf v0.4.1.tar.gz
RUN cd etcdctl-0.4.1 && ./build && mv bin/etcdctl /usr/local/bin/

ADD etcd_env.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/etcd_env.sh
