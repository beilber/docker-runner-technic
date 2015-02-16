# Table of Contents
- [Introduction](#introduction)
- [Contributing](#contributing)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Data Store](#data-store)
- [Shell Access](#shell-access)
- [Upgrading](#upgrading)

# Introduction

A CI runner for building a Technic Pack compatable Archive.

Built on top of the [sameersbn/gitlab-ci-runner](https://github.com/sameersbn/docker-gitlab-ci-runner) base image, this repo demonstrates the use of sameersbn/gitlab-ci-runner to build a runner for your project.

Since we inherit the [sameersbn/gitlab-ci-runner](https://github.com/sameersbn/docker-gitlab-ci-runner) base image, we also inherit its runtime. This means we only have to setup the image to satisfy your projects build requirements which in this case is gitlab-ce.

All package installations are performed in the [Dockerfile](https://github.com/beilber/docker-runner-technic/blob/master/Dockerfile) while the system configuration, such as mysql and redis setup, are performed in the [install](https://github.com/beilber/docker-runner-technic/blob/master/assets/setup/install) script.

Rest of this document describes use of the runner to perform continuous integration for Technic Packs.

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/sameersbn/docker-runner-gitlab/issues) they may encounter
- Send me a tip via [Bitcoin](https://www.coinbase.com/sameersbn) or using [Gratipay](https://gratipay.com/sameersbn/)

# Installation

Pull the latest version of the image from the docker index.

```bash
docker pull beilber/docker-runner-technic:latest
```

Alternately you can build the image yourself.

```bash
git clone https://github.com/beilber/docker-runner-technic.git
cd docker-runner-technic
docker build --tag="$USER/docker-runner-technic" .
```

# Quick Start
For a runner to do its trick, it has to first be registered/authorized on the GitLab CI server. This can be done by running the image with the **app:setup** command.

```bash
mkdir -p /opt/docker-runner-technic/data
#For use with SELinux, recomended
chcon -Rt svirt_sandbox_file_t /opt/docker-runner-technic/data
docker run --name runner-technic -i -t --rm \
	-v /opt/docker-runner-technic/data:/home/gitlab_ci_runner/data \
	beilber/docker-runner-technic:latest app:setup
```

The command will prompt you to specify the location of the GitLab CI server and provide the registration token to access the server. With this out of the way the image is ready, lets get is started.

```bash
docker run --name runner-technic -d \
	-v /opt/docker-runner-technic/data:/home/gitlab_ci_runner/data  \
	beilber/docker-runner-technic:latest
```

You now have the runner to perform continous integration.

Login to your GitLab CI server and add a CI build with the following build settings, modified to your needs since this is a bit crude:

```bash
git submodule update --init
DROP_PATH="/drop"
PACKNAME=`head -1 README.md`
VERSION=`head -1 changelog.txt  | cut -f 1 -d '-'`
OUTFILE="${PACKNAME}-${VERSION}.zip"
URL="http://files.example.com/${OUTFILE}
zip -9 -r --exclude=*.git --exclude=README.md --exclude=changelog.txt ${DROP_PATH}/${OUTFILE} *

if [ -f  ${DROP_PATH}/${OUTFILE} ]
then
  mkdir tmp
  cd tmp
  wget ${URL}
  unzip ${OUTFILE}
  ls -la
else
  echo "File not on drop"
  exit 1
fi
```

# Data Store
GitLab CI Runner saves the configuration for connection and access to the GitLab CI server. In addition, SSH keys are generated as well. To make sure this configuration is not lost when when the container is stopped/deleted, we should mount a data store volume at

* /home/gitlab_ci_runner/data

Volumes can be mounted in docker by specifying the **'-v'** option in the docker run command.

```bash
mkdir /opt/runner-technic/data
#For use with SELinux, recomended
chcon -Rt svirt_sandbox_file_t /opt/docker-runner-technic/data
docker run --name runner-technic -d -h runner-technic.local.host \
  -v /opt/runner-technic/data:/home/gitlab_ci_runner/data \
  beilber/docker-runner-technic:latest
```

# Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it runner-technic bash
```

If you are using an older version of docker, you can use the [nsenter](http://man7.org/linux/man-pages/man1/nsenter.1.html) linux tool (part of the util-linux package) to access the container shell.

Some linux distros (e.g. ubuntu) use older versions of the util-linux which do not include the `nsenter` tool. To get around this @jpetazzo has created a nice docker image that allows you to install the `nsenter` utility and a helper script named `docker-enter` on these distros.

To install `nsenter` execute the following command on your host,

```bash
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
```

Now you can access the container shell using the command

```bash
sudo docker-enter runner-technic
```

For more information refer https://github.com/jpetazzo/nsenter

## Upgrading

To update the runner, simply stop the image and pull the latest version from the docker index.

```bash
docker stop runner-technic
docker pull beilber/docker-runner-technic:latest
docker run --name runner-technic -d [OPTIONS] beilber/docker-runner-technic:latest
```
