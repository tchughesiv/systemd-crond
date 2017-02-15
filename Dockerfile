FROM centos:7
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>

COPY user_setup systemd_setup /tmp/

RUN yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
### Add your package needs to this installation line
    yum -y install cronie && \
    yum clean all

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root \
    USER_NAME=default \
    USER_UID=10001
ENV APP_HOME=${APP_ROOT}/src  PATH=$PATH:${APP_ROOT}/bin
RUN mkdir -p ${APP_HOME} ${APP_ROOT}/etc
COPY bin/ ${APP_ROOT}/bin/
RUN chmod -R ug+x ${APP_ROOT}/bin ${APP_ROOT}/etc /tmp/user_setup /tmp/systemd_setup && \
    /tmp/user_setup

####### Add app-specific needs below. #######
### systemd requirements - to cleanly shutdown systemd, use SIGRTMIN+3
STOPSIGNAL SIGRTMIN+3
ENV container=docker
RUN systemctl set-default multi-user.target && \
    systemctl enable crond && \
    /tmp/systemd_setup

### Containers should NOT run as root as a good practice
USER ${USER_UID}
WORKDIR ${APP_ROOT}
### arbitrary uid recognition at runtime - for OpenShift deployments
RUN sed "s@${USER_NAME}:x:${USER_UID}:@${USER_NAME}:x:\${USER_ID}:@g" /etc/passwd > ${APP_ROOT}/etc/passwd.template
CMD [ "/sbin/init" ]
