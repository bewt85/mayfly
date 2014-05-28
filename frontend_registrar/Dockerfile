# Docker version 0.11.1

FROM bewt85/etcdctl:0.4.1 

RUN apt-get update
RUN apt-get install -y python2.7 python-pip python-dev libssl-dev vim git

ADD requirements.txt /etc/mayfly/
RUN pip install -r /etc/mayfly/requirements.txt 

RUN sudo apt-get install -y incron
RUN echo 'root' >> /etc/incron.allow
ADD incron.root /var/spool/incron/root

VOLUME ["/etc/mayfly/environments/"]

ADD bin/        /usr/local/bin
RUN chmod -R +x /usr/local/bin

CMD ["bash"]
