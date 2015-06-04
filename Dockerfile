FROM sameersbn/gitlab-ci-runner:latest
MAINTAINER sameer@damagehead.com

RUN apt-get update && \
    apt-get install -y build-essential cmake openssh-server ruby2.1-dev 

RUN apt-get install libmysqlclient-dev zlib1g-dev libyaml-dev libssl-dev libgdbm-dev 

RUN apt-get install libreadline-dev libncurses5-dev libffi-dev  python-dev libxml2-dev

RUN apt-get install libxslt-dev libcurl4-openssl-dev libicu-dev python-pip zip unzip

RUN apt-get install  mysql-server mysql-client redis-server fontconfig

RUN gem install --no-document bundler

RUN pip install shyaml

RUN rm -rf /var/lib/apt/lists/* # 20140918


ADD assets/ /app/

RUN chmod 755 /app/setup/install

RUN /app/setup/install
