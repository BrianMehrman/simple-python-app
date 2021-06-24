# postgres-operator test

This tests the []()

# Getting Started

## Create a Kind cluster
Create a kind cluster locally

```
kind create cluster --name=test-env
```

## Create postgres-operator
Follow this [quickstart](https://github.com/zalando/postgres-operator/blob/master/docs/quickstart.md)
to setup the Zalando Postgres Operator.

From the zolando/postgres-opertator directory.

```
kubectl apply -k manifests/
kubectl apply -k ui/manifests/
```

## Start app

From the root of this project.

```
bin/run-app.sh
```

## Load data

From the root of this project.

```
bin/run-job.sh
```