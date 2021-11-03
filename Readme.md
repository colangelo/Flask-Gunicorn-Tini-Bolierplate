# Flask 2 + Gunicorn + Tini : Boilerplate app

This Flask 2 app has the following features:

- uses Gunicorn webserver
- uses Tini: an init specifically built for containers (see reference below)
- Gunicorn is set to reload at every change to the app.py file
- has curl, netcat, ps and vi (vim-tiny) commands installed
- runs as the non root user "web"
- uses multistage build
- uses Python 3.10 Debian Bullseye Slim image (less than 150 MB)
- can be deployed to Kubernetes (with or without nginx ingress)

Reference for Tini:

- [https://github.com/krallin/tini]()
- [https://github.com/krallin/tini/issues/8]()

Reference for Flask and Gunicorn ENV variables:

- [https://flask.palletsprojects.com/en/2.0.x/cli/]()
- [https://docs.gunicorn.org/en/stable/settings.html]()

## Test the app

```sh
# Create pipenv virtualenv
pipenv install -r requirements.txt

# Debug using Gunicorn
pipenv run gunicorn --reload --bind 0.0.0.0:8000 app:app
```

Build container and run in Docker

```sh
# Build container
export DOCKER_BUILDKIT=1
docker image build -t flask-gunicorn-tini:v1 .

# Start the container in Docker
docker run -d -p 8000:8000 flask-gunicorn-tini:v1

# Enter the container to test it
docker exec -it <container_id> /bin/bash
```

Deploy to Minikube / Kubernetes

```sh
# Enable Minikube docker
eval $(minikube docker-env)

# Build container
export DOCKER_BUILDKIT=1
docker image build -t flask-gunicorn-tini:v1 .

# Create deployment and service
kubectl apply -f kubernetes/deployment.yaml -f kubernetes/service.yaml

# Create nginx ingress
kubectl apply -f kubernetes/ingress.yaml

# Update service to LoadBalancer (requires MetalLB on Minikube)
kubectl apply -f kubernetes/service-lb.yaml
```
