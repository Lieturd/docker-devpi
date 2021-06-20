docker-devpi
============

This repository contains a Dockerfile for [devpi pypi server](http://doc.devpi.net/latest/). Based on [https://github.com/muccg/docker-devpi](https://github.com/muccg/docker-devpi).

You can use this container to speed up the `pip install` parts of your 
docker builds. This is done by adding an optional cache of your 
requirement python packages and speed up docker. The outcome is faster 
development without breaking builds.

# Getting started

Published on Docker hub as `lieturd/devpi`.

## Kubernetes

Deploying this to kubernetes could be done with something like:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pypi-cache
spec:
  selector:
    matchLabels:
      app: pypi-cache
  replicas: 1
  template:
    metadata:
      labels:
        app: pypi-cache
    spec:
      containers:
        - name: pypi-cache
          image: lieturd/devpi:latest
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3141
              name: pypi
---

apiVersion: v1
kind: Service
metadata:
  name: pypi-cache
spec:
  type: LoadBalancer
  ports:
    - port: 3141
      name: pypi
      protocol: TCP
      targetPort: 3141
  selector:
    app: pypi-cache
```

# Persistence

For devpi to preserve its state across container shutdown and startup you
should mount a volume at `/data`. The quickstart command already includes this.

# Security

Devpi creates a user named root by default, its password should be set
with `DEVPI_PASSWORD` environment variable. If not set, a random one
will be generated.

For additional security the argument `--restrict-modify root` has been
added so only the root may create users and indexes.


# Financial support

This project has been made possible thanks to [Cocreators](https://cocreators.ee) and [Lietu](https://lietu.net). You can help us continue our open source work by supporting us on [Buy me a coffee](https://www.buymeacoffee.com/cocreators).

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/cocreators)
