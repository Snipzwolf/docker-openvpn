FROM arm32v6/alpine

ENV DEBCONF_NONINTERACTIVE_SEEN="true" \
    DEBIAN_FRONTEND="noninteractive"

RUN apk add --purge --no-cache -qf openvpn easy-rsa bash openresolv;

ADD src/*.sh /opt/
ADD src/server.conf /etc/openvpn/
ADD src/*.example /etc/openvpn/example/

RUN mkdir /etc/openvpn/routes && \
    touch /etc/openvpn/routes/DEFAULT && \
    chmod 0755 /opt/*.sh

VOLUME ["/etc/openvpn/server/", "/var/log/openvpn/"]

ENTRYPOINT ["/opt/entrypoint.sh"]
