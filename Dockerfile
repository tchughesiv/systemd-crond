FROM centos:7
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>
ENV container=docker

COPY systemd_setup /tmp/
COPY systemd_entrypoint /usr/local/bin/

RUN chmod u+x /tmp/systemd_setup && \
### Add your package needs to this installation line
    yum -y install cronie && \
    yum clean all

### systemd requirements - to cleanly shutdown systemd, use SIGRTMIN+3
STOPSIGNAL SIGRTMIN+3
RUN systemctl set-default multi-user.target && \
    systemctl enable crond && \
    /tmp/systemd_setup

### arbitrary uid recognition at runtime - for OpenShift deployments
RUN sed "s@root:x:0:@root:x:\${USER_ID}:@g" /etc/passwd > /etc/passwd.template
CMD [ "/sbin/init" ]
