FROM centos:7
MAINTAINER Tommy Hughes <tchughesiv@gmail.com>

COPY user_setup systemd_setup /tmp/

RUN yum -y install cronie && \
    yum clean all

### Setup user for build execution and application runtime
ENV APP_ROOT=/opt/app-root \
    USER_NAME=default \
    USER_UID=10001
ENV APP_HOME=${APP_ROOT}/src
RUN mkdir -p ${APP_HOME} ${APP_ROOT}/etc
RUN chmod -R ug+x ${APP_ROOT}/etc /tmp/user_setup /tmp/systemd_setup && \
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
CMD [ "/sbin/init" ]