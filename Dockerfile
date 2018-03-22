FROM jenkins/jenkins:lts
MAINTAINER macwinnie <dev@macwinnie.me>

ARG user=root
USER ${user}

RUN curl -fsSL https://get.docker.com/ | sh

# run on every (re)start of container
ENTRYPOINT [ "/sbin/tini", "--", "/usr/local/bin/jenkins.sh" ]
