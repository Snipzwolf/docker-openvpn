#!/usr/bin/env bash
EXTRA_SCRIPT="";
CREATE_CERTS="false";
CLIENT_CERTS=0;
SERVER_CONFIG="/etc/openvpn/server.conf";

while getopts s:n option
do
 case "${option}"
 in
 e) EXTRA_SCRIPT=${OPTARG};;
 s) CREATE_CERTS="true";;
 c) CLIENT_CERTS=`echo ${OPTARG} | sed -e 's/[^0-9]//g'`;;
 p) SERVER_CONFIG=${OPTARG};;
 esac
done

if [ -f "$EXTRA_SCRIPT" ]; then
	bash $EXTRA_SCRIPT;
fi

if [ ! -f "/etc/openvpn/server/certs_setup" ]; then
  for ((number=1;number < $CLIENT_CERTS;number++)){
    echo "creating client cert $number";
  }
  touch /etc/openvpn/server/certs_setup;
fi

exec /usr/sbin/openvpn --config $SERVER_CONFIG < /dev/null
