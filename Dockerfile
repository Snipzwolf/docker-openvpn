FROM ubuntu:xenial

ENV DEBCONF_NONINTERACTIVE_SEEN="true" \
    DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -qq && \
    apt-get install -qqy openvpn easy-rsa openresolv && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD src/cert_setup.sh src/entrypoint.sh /opt/
ADD src/server.conf /etc/openvpn/
ADD src/*.example /etc/openvpn/example/

RUN mkdir /etc/openvpn/routes && \
    touch /etc/openvpn/routes/DEFAULT && \
    chmod 0755 /opt/*.sh

VOLUME ["/etc/openvpn/server/", "/var/log/openvpn/"]

ENTRYPOINT ["/opt/entrypoint.sh"]
