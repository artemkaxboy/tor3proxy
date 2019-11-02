DockerHub: <https://cloud.docker.com/u/artemkaxboy/repository/docker/artemkaxboy/tor3proxy>

## Tor and 3proxy ![](https://github.com/artemkaxboy/tor3proxy/workflows/Tests/badge.svg?branch=master)

Tor and 3proxy (socks5 proxy configured to route through tor) docker container.
The main goal of this image is to allow you to reach web resources through
tor-network with a chane to protect access to your proxy with a password.

## What is Tor

Tor is free software and an open network that helps you defend against traffic
analysis, a form of network surveillance that threatens personal freedom and
privacy, confidential business activities and relationships, and state security.

## What is 3proxy

3proxy is a tiny free proxy server.

---

## How to use this image

**NOTE**: this image is setup by default to be a relay only (not an exit node)

To run the container with specific user/pass you have to run one of the
following commands:

    docker run -p 1080:1080 -d artemkaxboy/tor3proxy -u "user:password" \
        -u "user2:password2" ...

or

    docker run -p 1080:1080 -v /path/to/users/file:/users -d artemkaxboy/tor3proxy

To run the container with anonymous access run the
following commands (use it only in private networks or locally):

    docker run -p 1080:1080 -d artemkaxboy/tor3proxy

To get access to the network through the proxy, setup your device for using
SOCKS5 proxy, choose the port (default is 1080), type in your username
and password if needed.

### Exposing the port

    docker run -it -p 1080:1080 -d artemkaxboy/tor3proxy

**NOTE**: it will take a while for tor to bootstrap...

### Complex configuration

    docker run -it --rm artemkaxboy/tor3proxy -h
    Usage: torproxy.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -b ""       Configure tor relaying bandwidth in KB/s
                    possible arg: "[number]" - # of KB/s to allow
        -e          Allow this to be an exit node for tor traffic
        -l "<country>" Configure tor to only use exit nodes in specified
                    country required args: "<country>" (IE, "US" or "DE")
                    <country> - country traffic should exit in
        -n          Generate new circuits now
        -p "<password>" Configure tor HashedControlPassword for control port
        -s "<port>;<host:port>" Configure tor hidden service
                    required args: "<port>;<host:port>"
                    <port> - port for .onion service to listen on
                    <host:port> - destination for service request
        -u "<user>:<password>" User and password to get access through
                    SOCKS5 3proxy, may be included more than once

    The 'command' (if provided and valid) will be run instead of torproxy

PROXY USERS LIST

As well as setting up users by option `-u`, you may pass a list of
user/password as a volume file:

    docker run -p 1080:1080 -v /path/to/file/on/host:/users artemkaxboy/tor3proxy

The file must contain the list in the following format:
    
    users admin:CL:bigsecret test:CL:password test1:CL:password1
    users "test2:CR:$1$lFDGlder$pLRb4cU2D7GAT58YQvY49."
    users test3:NT:BD7DFBF29A93F93C63CB84790DA00E63
    users superadmin:mynewpassword

You might notice the quotes in the second line, they are needed because of
`$` symbol, it is a meta-symbol which is using in 3proxy configuration so
you must use quotes to escape it.

The following password types are supported:
* `CL` - clear text password (used if was not specified)
* `CR` - passwords encrypted by crypt() (MD5 only)
* `NT` - hex-string representing NT-password

Users list must be set up during container creation.

ENVIRONMENT VARIABLES

* `TORUSER` - If set use named user instead of 'tor' (for example root)
* `BW` - As above, set a tor relay bandwidth limit in KB, IE `50`
* `EXITNODE` - As above, allow tor traffic to access the internet from your IP
* `LOCATION` - As above, configure the country to use for exit node selection
* `PASSWORD` - As above, configure HashedControlPassword for control port
* `SERVICE` - As above, configure hidden service, IE '80;hostname:80'
* `TZ` - Configure the zoneinfo timezone, IE `EST5EDT`
* `USERID` - Set the UID for the app user
* `GROUPID` - Set the GID for the app user

Other environment variables beginning with `TOR_` will edit the configuration
file accordingly:

* `TOR_NewCircuitPeriod=400` will translate to `NewCircuitPeriod 400`

### Examples

Any of the commands can be run at creation with `docker run` or later with
`docker exec -it tor torproxy.sh` (as of version 1.3 of docker).

#### Setting the Timezone

    docker run -it -p 1080:1080 -e TZ=EST5EDT -d artemkaxboy/tor3proxy

#### Start tor3proxy setting the allowed bandwidth

    docker run -it -p 1080:1080 -d artemkaxboy/tor3proxy -b 100

OR

    docker run -it -p 1080:1080 -e BW=100 -d artemkaxboy/tor3proxy

#### Start tor3proxy configuring it to be an exit node

    docker run -it -p 1080:1080 -d artemkaxboy/tor3proxy -e

OR

    docker run -it -p 1080:1080 -e EXITNODE=1 -d artemkaxboy/tor3proxy

### Test the proxy

    curl -Lxv --socks5 <ipv4_address>:1080 --proxy-user <user>:<password> http://jsonip.com

OR if you allowed anonymous access

    curl -Lxv --socks5 <ipv4_address>:1080 http://jsonip.com

---

If you wish to adapt the default configuration, use something like the following
to copy it from a running container:

    docker cp torproxy:/etc/tor/torrc /some/torrc

Then mount it to a new container like:

    docker run -it -p 1080:1080 -v /some/torrc:/etc/tor/torrc:ro \
        -d artemkaxboy/tor3proxy

## User Feedback

### Issues

#### tor failures (exits or won't connect)

If you are affected by this issue (a small percentage of users are) please try
setting the TORUSER environment variable to root, IE:

    docker run -it -p 1080:1080 -e TORUSER=root -d artemkaxboy/tor3proxy

#### Reporting

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/artemkaxboy/tor3proxy/issues).
