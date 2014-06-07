FROM ctlc/haproxy

RUN sudo apt-get install -y incron

RUN echo 'root' >> /etc/incron.allow

ADD incron.root /var/spool/incron/root

ADD run.sh /run.sh

VOLUME ["/etc/haproxy"]

EXPOSE 80
CMD ["/run.sh"]
