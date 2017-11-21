FROM openjdk:8-slim
LABEL maintainer="Alex Simenduev <shamil.si@gmail.com>"

# those are allowed to be changed at build time`
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV JENKINS_HOME=/var/jenkins_home \
    JENKINS_USER=${user}

RUN apt-get update \
    && apt-get install -y curl dumb-init git libltdl7 \
    && rm -rf /var/lib/apt/lists/* \
    \
    # Jenkins is run with user `jenkins`, uid = 1000
    # If you bind mount a volume from the host or a data container,
    # ensure you use the same uid
    && groupadd -g ${gid} ${group} \
    && useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod +x /usr/local/bin/jenkins-slave

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/jenkins-slave"]