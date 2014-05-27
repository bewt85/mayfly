# Docker version 0.11.1

FROM bewt85/etcdctl:0.4.1 

RUN apt-get update
RUN apt-get install -y vim

ADD run.sh /run.sh

ENTRYPOINT ["/run.sh"]
