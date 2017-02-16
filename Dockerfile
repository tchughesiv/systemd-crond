FROM centos:7
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>

COPY systemd_setup /tmp/
COPY bin/systemd_entrypoint /usr/local/bin/

RUN yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
### Add your package needs to this installation line
    yum -y install cronie && \
    yum clean all

####### Add app-specific needs below. #######
### systemd requirements - to cleanly shutdown systemd, use SIGRTMIN+3
STOPSIGNAL SIGRTMIN+3
ENV container=docker
RUN systemctl set-default multi-user.target && \
    systemctl enable crond && \
    /tmp/systemd_setup

WORKDIR ${APP_ROOT}
### arbitrary uid recognition at runtime - for OpenShift deployments
RUN sed "s@root:x:0:root:x:\${USER_ID}:@g" /etc/passwd > /etc/passwd.template
CMD [ "/sbin/init" ]
