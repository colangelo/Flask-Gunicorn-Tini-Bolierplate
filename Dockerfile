###########
# BUILDER #
###########

# pull official base image
FROM python:3.10-slim-bullseye as builder

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1 \
    PYTHONUNBUFFERED 1

# install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# lint
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir flake8==3.9.1
COPY . /usr/src/app/
RUN flake8 --ignore=E501,F401 .

# install python dependencies
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt


#########
# FINAL #
#########

# pull official base image
FROM python:3.10-slim-bullseye

# create directory for the app user and create the app user
ENV USERNAME=web
RUN mkdir -p /home/${USERNAME} && \
    addgroup --system ${USERNAME} && adduser --system --group ${USERNAME}

# create the appropriate directories
ENV HOME=/home/${USERNAME} \
    APP_HOME=/home/${USERNAME}/app
RUN mkdir ${APP_HOME}
WORKDIR ${APP_HOME}

# install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends procps netcat curl vim-tiny && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir /wheels/*

# copy project
COPY . ${APP_HOME}

# chown all the files to the app user
RUN chown -R ${USERNAME}:${USERNAME} ${APP_HOME}

# Explicit Gunicorn settings
ENV GUNICORN_CMD_ARGS="--reload --workers=2 --access-logfile=- --access-logformat='%(l)s %(t)s \"%(r)s\" %(s)s %(b)s \"%(f)s\" \"%(a)s\" %(D)s'"
# ENV GUNICORN_CMD_ARGS="--workers=3 --access-logfile=-"

# change to the app user
USER ${USERNAME}

EXPOSE 8000

# ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
ENTRYPOINT ["gunicorn", "--bind", "0.0.0.0:8000"]
CMD ["app:app"]
