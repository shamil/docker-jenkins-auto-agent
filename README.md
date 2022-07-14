# Jenkins auto agent

A docker image of Jenkins `JNLP` based agent. This image can self-register to Jenkins master, it will also unregister from the master when container exits. Another cool feature is that this image doesn't have `agent.jar` pre installed, instead it downloads it from Jenkins master when the container starts. This approach will help to avoid versioning problems that might happen between `master` and `agent`.

***

## Environment variables

**most used variables:**

- `JENKINS_AUTH` jenkins server username and either password or API token (in `user:secet` format)
- `JENKINS_URL` jenkins master url (example `http://localhost:8080`)
- `JENKINS_AGENT_LABEL` space delimited labels, used to group agents into one logical group (no default)
- `JENKINS_AGENT_MODE` how Jenkins schedules builds on this node, `NORMAL/EXCLUSIVE` (default is `NORMAL`)
- `JENKINS_AGENT_NAME` the name which will be used when registering (default is `$HOSTNAME`)
- `JENKINS_AGENT_NUM_EXECUTORS` number of executors to use (defaults to `1`)

less used and can keep the defaults

- `DOCKER_GROUP` the docker group name, should be same as the docker's host group (defaults to `docker`)
- `DOCKER_SOCKET` the docker socket location (default is `/var/run/docker.sock`)
- `JAVA_OPTS` pass java options to the `agent.jar` process (default is not set)
- `JENKINS_AGENT_CONNECTION_MODE` the connection mode to use to connect to the jenkins's master (default `-http`). If jenkins is running behind a reverse proxy it is advisable to use `-webSocket` to avoid connection problems (for more details see https://www.jenkins.io/doc/book/managing/cli/)

***

## Required permissions

The image should be used in trusted environment, even so the permissions for the user that will be used to register the agents should be restricted.

> **DO NOT USE ADMIN USER**

Therefore, in order to be able to self register to the master, a user with relevant permissions must be created.

The required permissions are:

- `Overall/Read`
- `Agent/Connect`
- `Agent/Create`
- `Agent/Delete`
- `Agent/ExtendedRead`

***

## Running

when running without any env variables:

```sh
$ docker run --rm simenduev/jenkins-auto-slave
please set both JENKINS_URL and JENKINS_AUTH env. variables
example:
JENKINS_AUTH=user:password
JENKINS_URL=http://localhost:8080
```

the basic working command:

```sh
$ docker run -d \
    --net host \
    -e JENKINS_URL=http://jenkins.internal.domain:8080 \
    -e JENKINS_AUTH=registrator:1234567890123456789012  \
    -v /any/path/you/like:/var/jenkins_home \
    simenduev/jenkins-auto-slave
```

> Mounting of `/var/jenkins_home` volume is required in order for agent to be able to build jobs.

below command will also permit the agent run docker commands:

```sh
$ docker run -d \
    --net host \
    -e JENKINS_URL=http://jenkins.internal.domain:8080 \
    -e JENKINS_AUTH=registrator:1234567890123456789012  \
    -v /any/path/you/like:/var/jenkins_home \
    -v /run/docker.sock:/run/docker.sock \
    -v /usr/bin/docker:/usr/bin/docker \
    simenduev/jenkins-auto-slave
```
