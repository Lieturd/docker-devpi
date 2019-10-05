FROM jfloff/alpine-python:3.6
LABEL maintainer="https://github.com/lieturd/"

ENV DEVPI_SERVER_VERSION=5.1.0 \
    DEVPI_WEB_VERSION=3.5.2 \
    DEVPI_CLIENT_VERSION=5.0.0 \
    PIP_NO_CACHE_DIR="off" \
    PIP_TRUSTED_HOST="127.0.0.1" \
    VIRTUAL_ENV=/env \
    PATH=/env/bin:$PATH

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN pip install virtualenv \
 && apk add --virtual build-deps \
        libffi-dev \
 && virtualenv $VIRTUAL_ENV \
 && $VIRTUAL_ENV/bin/pip install -U pip \
 && pip install \
    "devpi-client==${DEVPI_CLIENT_VERSION}" \
    "devpi-web==${DEVPI_WEB_VERSION}" \
    "devpi-server==${DEVPI_SERVER_VERSION}" \
  && chmod +x /docker-entrypoint.sh \
  && apk del build-deps \
  && rm -rf "/var/cache/apk"

ENV HOME /data
WORKDIR /data

EXPOSE 3141

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["devpi"]
