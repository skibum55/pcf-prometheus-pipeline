#!/bin/bash
set -e
CURL="om --target https://${opsman_url} -k \
  --username $pcf_opsman_admin_username \
  --password $pcf_opsman_admin_password \
  curl"

bosh -n target `cat om-bosh-creds/director_ip`

BOSH_USERNAME=$(cat om-bosh-creds/bosh-username)
BOSH_PASSWORD=$(cat om-bosh-creds/bosh-pass)

echo "Logging in to BOSH..."
bosh login <<EOF 1>/dev/null
$BOSH_USERNAME
$BOSH_PASSWORD
EOF

echo "Interpolating..."
eval "echo \"$(cat pcf-prometheus-git/tasks/etc/local.yml)\"" > local.yml
bosh-cli interpolate pcf-prometheus-manifest/prometheus-no-route.yml -l local.yml > manifest.yml


echo "Deploying..."

bosh -n deployment manifest.yml

bosh -n deploy --no-redact
