# Simple Web App

This app is built using python, postgres, and redis. 
 * It takes a name entered from a webform
 * enters that name in redis
 * Take that name from redis and enters it into postgres
 * The names are read from postgres and display on a webpage


## Dependencies

* Python
* Poetry (local dev only)
* Redis
* Postgres
* Kubernetes cluster

All dependencies are provided using Kubernetes. 

## Install

install poetry

```
curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
```

install dependencies

```
poetry install
```

Postgres will need to be running locally to develop on this app. You can use the `base` Kubernetes configs for that.

```
kubectl apply -k kubernetes/base
```

## Usage

setup environment variables

```
export PYTHONPATH=$(pwd) 
export DATABASE_URL="postgresql://postgres:password@localhost:5432/simple_database"
export FLASK_APP=simple_web_app.app
```

## Start


To run the flask app 
```
poetry run python simple_web_app/app.py
```

Load sample data

```
poetry run python load.py
```

## Docker

```
docker build -t bcmehrman/simple-python-app -f docker/Dockerfile .
```

## Kubernetes

Process
* Deploy Postgres and Redis
* Once they are stable deploy web app
 * Init container will load seed data
 * Once data is loads app will start  

 ```
 kubectl apply -k kubernetes/overlays/staging
 ```


 ## Sources

 * Poetry Docker [link](https://stackoverflow.com/questions/53835198/integrating-python-poetry-with-docker)
 * Flask / SQLAlchemy [link](https://towardsdatascience.com/use-flask-and-sqlalchemy-not-flask-sqlalchemy-5a64fafe22a4)