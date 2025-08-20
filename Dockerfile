FROM eclipse-temurin:21-jre-noble
LABEL maintainer="Alex Simenduev <shamil.si@gmail.com>"

# Those are allowed to be changed at build time
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

ENV JENKINS_HOME=/var/jenkins_home \
    JENKINS_USER=${user}

# Remove the built-in `ubuntu` user and group to restore a clean state
RUN userdel -fr ubuntu

RUN apt-get update \
    && apt-get install -y --no-install-recommends dumb-init git git-lfs libltdl7 openssh-client ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    # Install docker
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    # Only the docker-ce-cli is required since the other components are externally provided
    && apt-get install -y docker-ce-cli \
    # Jenkins is run with user `jenkins`, uid = 1000
    # If you bind mount a volume from the host or a data container,
    # ensure you use the same uid
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
RUN mv /usr/bin/docker /usr/bin/docker-orig
COPY docker /usr/bin/docker
RUN chmod +x /usr/bin/docker

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/jenkins-agent"]
