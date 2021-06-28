#!/bin/bash

: ${RUN_ACTION='apply'}
export host='postgres';
export port="5432";
export password='password';
export username='postgres';
export database="simple_database";

scriptdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
base="kubernetes/overlays/staging/simple-app/load-data"
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