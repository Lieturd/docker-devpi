#!/usr/bin/env sh

set -exu

: ${REPLICA_MAX_RETRIES:=40}
: ${REQUEST_TIMEOUT:=30}

function defaults {
    : ${DEVPI_SERVERDIR="/data/server"}
    : ${DEVPI_CLIENTDIR="/data/client"}

    # Generate random password if none specified
    if [ -z ${DEVPI_PASSWORD:-} ]; then
        DEVPI_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})
    fi

    echo "DEVPI_SERVERDIR is ${DEVPI_SERVERDIR}"
    echo "DEVPI_CLIENTDIR is ${DEVPI_CLIENTDIR}"
    echo "DEVPI_PASSWORD is ${DEVPI_PASSWORD}"

    export DEVPI_SERVERDIR DEVPI_CLIENTDIR DEVPI_PASSWORD
}

function initialise_devpi {
    echo "[RUN]: Initialise devpi-server"
    devpi-server --restrict-modify root --start --host 127.0.0.1 --port 3141 --init
    devpi-server --status
    devpi use http://localhost:3141
    devpi login root --password=''
    devpi user -m root password="${DEVPI_PASSWORD}"
    devpi index -y -c public pypi_whitelist='*'
    devpi-server --stop
    devpi-server --status
}

defaults

if [ "$1" = 'devpi' ]; then
    if [ ! -f  $DEVPI_SERVERDIR/.serverversion ]; then
        initialise_devpi
    fi

    echo "[RUN]: Launching devpi-server"
    exec devpi-server --restrict-modify root --host 0.0.0.0 --port 3141 --replica-max-retries $REPLICA_MAX_RETRIES --request-timeout $REQUEST_TIMEOUT
fi

echo "[RUN]: Builtin command not provided [devpi]"
echo "[RUN]: $@"

exec "$@"
