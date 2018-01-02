# docker-openvpn

docker container with openvpn installed and entrypoint script to generate the required easy-rsa certificates, keys, etc.

# Command Options

All the options below are optional however without any the container will fail to start

* -e <SCRIPT_PATH>
  * run a script before starting openvpn
* -s
  * if /etc/openvpn/server/certs_setup does not exist, executes all the easy-rsa certificate setup for the server and if required for clients too
* -c NUMBER_OF_CLIENTS
  * requires ```-s``` and will generate the requested number of client certificates and keys
* -k <CONFIG_PATH>
  * requires ```-s``` and will replace the default easy-rsa vars file with the specified one
* -p <CONFIG_PATH>
  * specify the path of the config openvpn will start with
* -i <COMMON_NAME>
  * requires ```-s``` and will generate the sever certificate with the specified CN (note this also changes the certificate filename)

# Environment Variables

Name | Description | Default Value
--- | --- | ---
OPENVPN_USERNAME | creates a user with this username on startup | openvpn
OPENVPN_UID | creates a user with this uid on startup | 500
OPENVPN_GROUPNAME | creates a group with this name on startup | openvpn
OPENVPN_GID | creates a group with this gid on startup | 500

# Example Usage

```
docker run -it --name openvpn-server \
  --log-driver json-file --log-opt max-size=10m --cap-add=NET_ADMIN \
  -v `pwd`/openvpn-server/:/etc/openvpn/server/ \
  -p 1194:1194/udp \
    snipzwolf/docker-openvpn -s -c 5 -i "server.example.com" -o "client@@.example.com"
```
Creates a new server with 5 client certificates, requires a valid openvpn config file at $PWD/openvpn-server/server.conf on the host

```
docker run -it --name openvpn-server \
  --log-driver json-file --log-opt max-size=10m --cap-add=NET_ADMIN \
  -v `pwd`/my_setup_script.sh:/my_setup_script.sh \
  -v `pwd`/my_own_config.conf:/my_own_config.conf \
  -p 1194:1194/udp \
    snipzwolf/docker-openvpn -e /my_setup_script.sh -p /my_own_config.conf
```
Creates a new server running my_setup_script.sh on each startup and using my_own_config.conf as the openvpn config

<!--
## Useful Commands
* ``` openssl x509 -text -noout -in blah.crt ```
  * inside the container to dump the
-->
