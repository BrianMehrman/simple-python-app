#!/bin/bash

: ${RUN_ACTION='apply'}
: ${NAMESPACE='default'}

export host='postgres';
export port="5432"
export password='password'
export username='postgres'
export database="simple_database"
scriptdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
base="kubernetes/overlays/staging"
tmp_dir=$(mktemp -d tmp/ci-XXXXXXXXXX)

echo "Temp dir: ${tmp_dir}"
cd $tmp_dir

echo "Creating new kustomization"
kustomize create --autodetect

echo "Setting namespace ${NAMESPACE}"
kustomize edit set namespace "${NAMESPACE}"

echo "Adding resource from  ${base}"
kustomize edit add resource "../../${base}"

echo "Creating patch for db"
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

kustomize build . >> build.yaml
cat build.yaml
kubectl ${RUN_ACTION} -f build.yaml