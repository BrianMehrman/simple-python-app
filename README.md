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

## Usage

```
export PYTHONPATH=$(pwd) 
export DATABASE_URL="postgresql://postgres:password@localhost:5432/simple_database"
export FLASK_APP=simple_web_app.app
```

## Docker

## Kubernetes

Process
* Deploy Postgres and Redis
* Once they are stable deploy web app
 * Init container will load seed data
 * Once data is loads app will start  