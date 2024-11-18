FROM eclipse-temurin:21-jre-noble
LABEL maintainer="Alex Simenduev <shamil.si@gmail.com>"

# Those are allowed to be changed at build time
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV JENKINS_HOME=/var/jenkins_home \
    JENKINS_USER=${user}

RUN apt-get update \
    && apt-get install -y --no-install-recommends dumb-init git git-lfs libltdl7 openssh-client \
    && rm -rf /var/lib/apt/lists/* \
    \
    # Jenkins is run with user `jenkins`, uid = 1000
    # If you bind mount a volume from the host or a data container,
    # ensure you use the same uid
    && if id -u ${uid}; then userdel $(id -n -u ${uid}) ; fi \
    && groupadd -f -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
    \
    # Tweak global SSH client configuration
    && sed -i '/^Host \*/a \ \ \ \ ServerAliveInterval 30' /etc/ssh/ssh_config \
    && sed -i '/^Host \*/a \ \ \ \ StrictHostKeyChecking no' /etc/ssh/ssh_config \
    && sed -i '/^Host \*/a \ \ \ \ UserKnownHostsFile /dev/null' /etc/ssh/ssh_config

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

COPY jenkins-agent /usr/local/bin/jenkins-agent

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/jenkins-agent"]
