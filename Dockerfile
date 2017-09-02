FROM alpine:latest as builder

RUN apk update && apk upgrade && apk add --no-cache \
    bash --virtual .build-dependencies curl alpine-sdk automake autoconf bison flex libtool linux-headers util-linux

RUN mkdir -p /tmp/collectd && curl -sL `curl -s https://api.github.com/repos/collectd/collectd/releases/latest | grep tarball_url | head -n 1 | cut -d '"' -f 4` | tar xz -C /tmp/collectd --strip-components=1 && \
    cd /tmp/collectd && \
    ./build.sh && \
    ./configure && \
    make all install


FROM alpine:latest

RUN apk update && apk add --no-cache libltdl tzdata

COPY --from=builder   /opt/collectd  /opt/collectd


RUN ln -sf /dev/stout /var/log/collectd.log  && mkdir -p /opt/collectd/etc/collectd.conf.d

RUN echo $'<Include "/opt/collectd/etc/collectd.conf.d"> \n\
Filter "*.conf" \n\
</Include> \n'\
>> /opt/collectd/etc/collectd.conf && cat /opt/collectd/etc/collectd.conf

VOLUME /opt/collectd/etc/
VOLUME /opt/collectd/share/

CMD exec /opt/collectd/sbin/collectd -C /opt/collectd/etc/collectd.conf -f
