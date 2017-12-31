#!/usr/bin/env bash
EXTRA_SCRIPT="";
CREATE_CERTS="false";
CLIENT_CERTS=0;
SERVER_CONFIG="/etc/openvpn/server.conf";
EASYRSA_CONFIG="/etc/openvpn/easy-rsa-vars.example";

while getopts e:c:p:so option
do
 case "${option}"
 in
 e) EXTRA_SCRIPT=${OPTARG};;
 s) CREATE_CERTS="true";;
 c) CLIENT_CERTS=`echo ${OPTARG} | sed -e 's/[^0-9]//g'`;;
 p) SERVER_CONFIG=${OPTARG};;
 k) EASYRSA_CONFIG=${OPTARG};;
 esac
done

if [ -f "$EXTRA_SCRIPT" ]; then
	bash $EXTRA_SCRIPT;
fi

if [ $CREATE_CERTS = "true" ] && [ ! -f /etc/openvpn/server/certs_setup ]; then
  make-cadir /etc/openvpn/server/certs/;
  cd /etc/openvpn/server/certs/;

  cp -f $EASYRSA_CONFIG ./vars;
  source ./vars;
  ./clean-all;
  ./build-dh;
  ./pkitool --initca;
  ./pkitool --server server;

  for ((certNumber=1; certNumber <= $CLIENT_CERTS; certNumber++)){
    echo "creating client cert $certNumber";
    KEY_CN="client_$certNumber" ./pkitool "client_$certNumber";
  }

  cd keys;
  openvpn --genkey --secret ta.key;

  ls -lah

  touch /etc/openvpn/server/certs_setup;
fi

#exec /usr/sbin/openvpn --config $SERVER_CONFIG < /dev/null
