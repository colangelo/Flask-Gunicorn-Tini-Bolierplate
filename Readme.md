# Flask 2.0 + Gunicorn Boilerplate app

This Flask 2.0 app has the following features:

- uses Gunicorn webserver
- Gunicorn is set to reload at every change to the app.py file
- has curl, netcat, ps and vi (vim-tiny) commands installed
- runs as the non root user "web"
- uses multistage build
- uses Python 3.10 Debian Bullseye Slim image (less than 150 MB)
- can be deployed to Kubernetes (with or without nginx ingress)

Reference for Flask and Gunicorn ENV variables:

- [https://flask.palletsprojects.com/en/2.0.x/cli/]()
- [https://docs.gunicorn.org/en/stable/settings.html]()

## Test the app

```sh
# Run using Gunicorn
pipenv run gunicorn --bind 0.0.0.0:8000 app:app
```

Build container and run in Docker

```sh
#
export DOCKER_BUILDKIT=1
docker image build -t flask-gunicorn:v1 .

#
docker run -d -p 8000:8000 flask-gunicorn:v1

#
docker exec -it <container_id> /bin/bash
```

Deploy to Minikube / Kubernetes

```sh
# Enable Minikube docker
eval $(minikube docker-env)

# build
export DOCKER_BUILDKIT=1
docker image build -t flask-gunicorn:v1 .

# create deployment and service
kubectl apply -f kubernetes/deployment.yaml -f kubernetes/service.yaml

# create nginx ingress
kubectl apply -f kubernetes/ingress.yaml

# update service to LoadBalancer (requires MetalLB on Minikube)
kubectl apply -f kubernetes/service-lb.yaml
```
