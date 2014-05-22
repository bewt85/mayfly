FROM ctlc/haproxy

RUN sudo apt-get install -y incron

RUN echo 'root' >> /etc/incron.allow

ADD incron.root /var/spool/incron/root

ADD /supervisord-incron.conf /etc/supervisor/conf.d/supervisord-incron.conf
ADD /supervisord-haproxy.conf /etc/supervisor/conf.d/supervisord-haproxy.conf

VOLUME ["/etc/haproxy"]

EXPOSE 80
CMD ["/run.sh"]
