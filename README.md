## Jenkins auto slave

A docker image of Jenkins `JNLP` based agent. This image can self-register to Jenkins master, it will also unregister from the master when container exits. Another cool feature is that this image doesn't have `agent.jar` pre installed, instead it downloads it from Jenkins master when the container starts. This approach will help to avoid versioning problems that might happen between `master` and `slave`.

***

**Environment variables**

most used variables:

- `JENKINS_AUTH` jenkins server username and either password or API token (in `user:secet` format)
- `JENKINS_URL` jenkins master url (example `http://localhost:8080`)
- `JENKINS_SLAVE_NAME` the name which will be used when registering (default is `$HOSTNAME`)
- `JENKINS_SLAVE_NUM_EXECUTORS` number of executors to use (defaults to `1`)

less used and can keep the defaults

- `DOCKER_GROUP` the docker group name, should be same as the docker's host group (defaults to `docker`)
- `DOCKER_SOCKET` the docker socket location (default is `/var/run/docker.sock`)


***

**Running**

when running without any env variables:

```
$ docker run --rm simenduev/jenkins-auto-slave
please set both JENKINS_URL and JENKINS_AUTH env. variables
example:
JENKINS_AUTH=user:password
JENKINS_URL=http://localhost:8080
```

the basic working command:

```
$ docker run -d \
    --net host \
    -e JENKINS_URL=http://jenkins.internal.domain:8080 \
    -e JENKINS_AUTH=registrator:1234567890123456789012  \
    -v /any/path/you/like:/var/jenkins_home \
    simenduev/jenkins-auto-slave
```

> NOTE: mounting of `/var/jenkins_home` volume is required in order for agent to be able to build jobs.

below command will also permit the slave to use docker commands:

```shell
$ docker run -d \
    --net host \
    -e JENKINS_URL=http://jenkins.internal.domain:8080 \
    -e JENKINS_AUTH=registrator:1234567890123456789012  \
    -v /any/path/you/like:/var/jenkins_home \
    -v /run/docker.sock:/run/docker.sock \
    -v /usr/bin/docker:/usr/bin/docker
    simenduev/jenkins-auto-slave
```

***