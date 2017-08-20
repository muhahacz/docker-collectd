FROM alpine:latest

MAINTAINER muhahacz

RUN apk update && apk upgrade && apk add --no-cache \
    bash curl alpine-sdk automake autoconf bison flex libtool linux-headers util-linux && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /tmp/collectd && curl -sL `curl -s https://api.github.com/repos/collectd/collectd/releases/latest | grep tarball_url | head -n 1 | cut -d '"' -f 4` | tar xz -C /tmp/collectd --strip-components=1 \ 
&& cd /tmp/collectd && ls -lha /tmp/collectd && ./build.sh && ./configure &&  make all install

LABEL version=latest

CMD exec /opt/collectd/sbin/collectd -C /opt/collectd/etc/collectd.conf -f
