#!/usr/bin/env bash
EXTRA_SCRIPT="";

CREATE_CERTS="false";
CLIENT_CERTS=0;
SERVER_CN="server"
CLIENT_CN_TEMPLATE="client_@@";
SERVER_CONFIG="/etc/openvpn/server.conf";
EASYRSA_CONFIG="/etc/openvpn/easy-rsa-vars.example";

while getopts e:c:p:si:o: option
do
 case "${option}"
 in
 e) EXTRA_SCRIPT=${OPTARG};;
 s) CREATE_CERTS="true";;
 c) CLIENT_CERTS=`echo ${OPTARG} | sed -e 's/[^0-9]//g'`;;
 p) SERVER_CONFIG=${OPTARG};;
 k) EASYRSA_CONFIG=${OPTARG};;
 i) SERVER_CN=${OPTARG};;
 o) CLIENT_CN_TEMPLATE=${OPTARG};;
 esac
done

if [ -f "$EXTRA_SCRIPT" ]; then
	bash $EXTRA_SCRIPT;
fi

if [ $CREATE_CERTS = "true" ] && [ ! -f /etc/openvpn/server/certs_setup ]; then
  exec -c /bin/bash /opt/cert_setup.sh "$SERVER_CN" "$CLIENT_CN_TEMPLATE" $CLIENT_CERTS "$EASYRSA_CONFIG" < /dev/null;
fi

OPENVPN_USERNAME=${OPENVPN_USERNAME:-"openvpn"};
OPENVPN_UID=${OPENVPN_UID:-500};
OPENVPN_GROUPNAME=${OPENVPN_GROUPNAME:-"openvpn"};
OPENVPN_GID=${OPENVPN_GID:-500};
id -g $OPENVPN_GROUPNAME &>/dev/null || (groupadd -r $OPENVPN_GROUPNAME -g $OPENVPN_GID && echo "Created group $OPENVPN_GROUPNAME:$OPENVPN_GID");
id -u $OPENVPN_USERNAME &>/dev/null || (useradd $OPENVPN_USERNAME -rMN -u $OPENVPN_UID -g $OPENVPN_GID && echo "Created user $OPENVPN_USERNAME:$OPENVPN_UID");


[ -d /dev/net ] || mkdir -p /dev/net
[ -c /dev/net/tun ] || (mknod /dev/net/tun c 10 200 && chmod 0666 /dev/net/tun )

exec /usr/sbin/openvpn --config $SERVER_CONFIG < /dev/null
