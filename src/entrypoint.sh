#!/usr/bin/env bash
EXTRA_SCRIPT="";
CREATE_CERTS="false";
CLIENT_CERTS=0;
SERVER_CONFIG="/etc/openvpn/server.conf";
EASYRSA_CONFIG="/etc/openvpn/easy-rsa-vars.example";

SERVER_CN="server"
CLIENT_CN_TEMPLATE="client_@@";

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

#exec /usr/sbin/openvpn --config $SERVER_CONFIG < /dev/null
