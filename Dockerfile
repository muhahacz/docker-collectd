FROM alpine:latest as builder

RUN apk update && apk upgrade && apk add --no-cache \
    bash --virtual .build-dependencies curl alpine-sdk automake autoconf bison flex libtool linux-headers util-linux

RUN mkdir -p /tmp/collectd && curl -sL `curl -s https://api.github.com/repos/collectd/collectd/releases/latest | grep tarball_url | head -n 1 | cut -d '"' -f 4` | tar xz -C /tmp/collectd --strip-components=1 && \
    cd /tmp/collectd && \
    ./build.sh && \
    ./configure && \
    make all install


FROM alpine:latest

RUN apk update && apk add --no-cache libltdl

WORKDIR /opt/

COPY --from=builder   /opt/collectd  ./collectd

VOLUME /opt/collectd/etc/

CMD exec /opt/collectd/sbin/collectd -C /opt/collectd/etc/collectd.conf -f
