#!/usr/bin/env bash

SERVER_CN=$1
CLIENT_CN_TEMPLATE=$2;
CLIENT_CERTS=$3;
EASYRSA_CONFIG=$4;

make-cadir /etc/openvpn/server/certs/;
cd /etc/openvpn/server/certs/;
chmod -R 0770 /etc/openvpn/server/certs;

cp -f $EASYRSA_CONFIG ./vars;
source ./vars;
./clean-all;
./build-dh;
./pkitool --initca;

KEY_ALTNAMES="DNS:$SERVER_CN";
./pkitool --server $SERVER_CN;

for ((certNumber=1; certNumber <= $CLIENT_CERTS; certNumber++)){
  CLIENT_NAME=`echo $CLIENT_CN_TEMPLATE | sed -e "s/@@/$certNumber/g"`;

  echo "creating client cert $CLIENT_NAME";

  KEY_ALTNAMES="DNS:$CLIENT_NAME";
  ./pkitool $CLIENT_NAME;
}

./revoke-full does_not_exist #this will fail but creates crl.pem

cd keys;
openvpn --genkey --secret ta.key;

cp $SERVER_CN.crt $SERVER_CN.key ca.crt dh*.pem ta.key crl.pem /etc/openvpn/server/

if [ $CLIENT_CERTS > 0 ]; then
  mkdir -p /etc/openvpn/server/clients;
  CLIENT_CERT_WILDCARD=`echo $CLIENT_CN_TEMPLATE | sed -e "s/@@/*/g"`;
  cp $CLIENT_CERT_WILDCARD.crt $CLIENT_CERT_WILDCARD.key ca.crt dh*.pem ta.key /etc/openvpn/server/clients/
fi

touch /etc/openvpn/server/certs_setup;
