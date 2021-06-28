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

if [ -v RUN_IMAGE ]; then
    echo "Found image to replace: ${FROM_IMAGE}->${RUN_IMAGE}";
    kustomize edit set image ${FROM_IMAGE}=${RUN_IMAGE}
fi 

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

echo "Creating patch for deployment"
cat <<EOF >deployment-patch.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: web
spec:
    template:
        spec:
            containers:
            - name: web
              imagePullPolicy: Never
            initContainers:
            - name: run-migrations
              imagePullPolicy: Never

EOF

cat <<EOF >>kustomization.yaml
patchesStrategicMerge:
  - deployment-patch.yaml
EOF

cat kustomization.yaml
kustomize build . >> build.yaml
cat build.yaml
kubectl ${RUN_ACTION} -f build.yaml