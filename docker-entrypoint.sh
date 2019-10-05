#!/usr/bin/env sh

set -xu

: ${REPLICA_MAX_RETRIES:=40}
: ${REQUEST_TIMEOUT:=30}

function defaults {
    : ${DEVPISERVER_SERVERDIR="/data/server"}
    : ${DEVPI_CLIENTDIR="/data/client"}

    # Generate random password if none specified
    if [ -z ${DEVPI_PASSWORD:-} ]; then
        DEVPI_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32})
    fi

    echo "DEVPISERVER_SERVERDIR is ${DEVPISERVER_SERVERDIR}"
    echo "DEVPI_CLIENTDIR is ${DEVPI_CLIENTDIR}"
    echo "DEVPI_PASSWORD is ${DEVPI_PASSWORD}"

    export DEVPISERVER_SERVERDIR DEVPI_CLIENTDIR DEVPI_PASSWORD
}

function initialise_devpi {
    echo "[RUN]: Initialise devpi-server"

    devpi-server --restrict-modify root --init
    devpi-server --restrict-modify root --host 127.0.0.1 --port 3141 &
    PID=$!

    attempts=0
    while true; do
        devpi use http://127.0.0.1:3141
        if [ "$?" != "0" ]; then
            if [ "$attempts" -gt 10 ]; then
                echo "Failed to connect to server."
                exit 1
            fi
            attempts=$((attempts+1))
            sleep 1
        else
            break
        fi
    done

    devpi login root --password=''
    devpi user -m root password="${DEVPI_PASSWORD}"
    devpi index -y -c public bases=root/pypi

    kill -TERM $PID
    wait $PID
}

defaults

if [ "$1" = 'devpi' ]; then
    if [ ! -f $DEVPISERVER_SERVERDIR/.serverversion ]; then
        initialise_devpi
    fi

    echo "[RUN]: Launching devpi-server"
    exec devpi-server --restrict-modify root --host 0.0.0.0 --port 3141 --replica-max-retries $REPLICA_MAX_RETRIES --request-timeout $REQUEST_TIMEOUT
fi

echo "[RUN]: Builtin command not provided [devpi]"
echo "[RUN]: $@"

exec "$@"
