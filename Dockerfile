FROM phusion/baseimage:0.9.19
MAINTAINER Arne Jørgensen

RUN set -x && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q golang-go git php-cli php-curl ruby && \
    GOPATH=/usr/local go get -u github.com/xenolf/lego && \
    curl -sS https://platform.sh/cli/installer | php && \
    curl -sS -o /opt/yamledit.rb https://raw.githubusercontent.com/dbrandenburg/yamledit/master/yamledit.rb && \
    DEBIAN_FRONTEND=noninteractive apt-get purge -y -q golang-go && \
    apt-get clean -y -q && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH=/root/.platformsh/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY etc/ /etc/
COPY usr/ /usr/
VOLUME [ "/data" ]
