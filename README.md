# systemd-crond

In OpenShift 3.4 w/ oci-uid-hook enabled...
```shell
$ oc new-project systemd
$ oc project systemd
$ oc new-app https://raw.githubusercontent.com/tchughesiv/systemd-crond/master/systemd-ocp-template-centos7.yaml
```