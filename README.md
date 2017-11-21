### Jenkins auto slave

A docker image of Jenkins `JNLP` based agent. This image can self-register to Jenkins master, it will also unregister from the master when container exits.

**running**

    $ docker run --rm simenduev/jenkins-auto-slave
    please set both JENKINS_HOST and JENKINS_AUTH env. variables
    example:
    JENKINS_AUTH=user:password
    JENKINS_HOST=http://localhost:8080

> More info incoming, please stand by ...