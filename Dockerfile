FROM openjdk:8-alpine

# those are allowed to be changed at build time`
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN apk --no-cache add curl dumb-init git openssh-client bash jq

#Install Docker
RUN apk --no-cache add shadow su-exec docker
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

#Install kubectl
RUN curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubectl && chmod +x /usr/bin/kubectl

#Install aws cli
RUN apk --no-cache add groff python py-pip && \
    pip install awscli==1.15.21 s3cmd==2.0.1



ENV JENKINS_HOME=/var/jenkins_home \
    JENKINS_USER=${user}

RUN  groupadd -g ${gid} ${group} && \
     useradd -d "$JENKINS_HOME" -u ${uid} -g ${gid} -m -s /bin/bash ${user} && \
     sed -i '/^Host \*/a \ \ \ \ ServerAliveInterval 30' /etc/ssh/ssh_config && \
     sed -i '/^Host \*/a \ \ \ \ StrictHostKeyChecking no' /etc/ssh/ssh_config

# Jenkins home directory is a volume, so configuration and build history
# can be persisted and survive image upgrades
VOLUME $JENKINS_HOME

COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod +x /usr/local/bin/jenkins-slave

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/local/bin/jenkins-slave"]
