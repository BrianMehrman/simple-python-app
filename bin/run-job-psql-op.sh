#!/bin/bash

: ${RUN_ACTION='apply'}

export host=$(kubectl get services -o jsonpath={.items..metadata.name} -l application=spilo,cluster-name=acid-minimal-cluster,spilo-role=master -n default);
export port="5432"
export password=$(kubectl get secret postgres.acid-minimal-cluster.credentials -o 'jsonpath={.data.password}' | base64 -d)
export username=$(kubectl get secret postgres.acid-minimal-cluster.credentials -o 'jsonpath={.data.username}' | base64 -d)
export database="simple_database"

scriptdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
base="kubernetes/overlays/postgres-op/load-data"
tmp_dir=$(mktemp -d tmp/ci-XXXXXXXXXX)

echo "Temp dir: ${tmp_dir}"
cd $tmp_dir

kustomize create --autodetect
kustomize edit set namespace default
kustomize edit add resource "../../${base}"

cat <<EOF >db-patch.yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: config-app
data:
    DATABASE_HOST: ${host}
    DATABASE_URL: postgresql://${username}:${password}@${host}:${port}/${database}
    DATABASE_USERNAME: ${username}
    DATABASE_PASSWORD: ${password}
EOF

kustomize edit add patch --path db-patch.yaml --kind ConfigMap --name config-app

kustomize build . | kubectl ${RUN_ACTION} -f -