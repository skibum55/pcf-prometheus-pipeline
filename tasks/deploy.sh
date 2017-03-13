#!/bin/bash
set -e
CURL="om --target https://${opsman_url} -k \
  --username $pcf_opsman_admin_username \
  --password $pcf_opsman_admin_password \
  curl"

bosh -n --ca-cert om-bosh-creds/bosh-ca.pem target `cat om-bosh-creds/director_ip`

BOSH_USERNAME=$(cat om-bosh-creds/bosh-username)
BOSH_PASSWORD=$(cat om-bosh-creds/bosh-pass)

echo "Logging in to BOSH..."
bosh login <<EOF 1>/dev/null
$BOSH_USERNAME
$BOSH_PASSWORD
EOF

if [[ ! -z $opsman_url ]]; then
  echo "Getting NATS creds..."

  cf_id=$($CURL --path=/api/v0/deployed/products | jq -r ".[].guid" | grep cf-)

  nats_machines=$($CURL --path=/api/v0/deployed/products/$cf_id/status | \
    jq -r -c  '.status[] | select(."job-name" | contains("nats")) | .ips' | \
    perl -pe 's/\n//g' | perl -pe 's/\]\[/,/g')


  nats_creds=$($CURL --path=/api/v0/deployed/products/$cf_id/credentials/.nats.credentials)

  nats_username=$(echo $nats_creds | jq -r .credential.value.identity)
  nats_password=$(echo $nats_creds | jq -r .credential.value.password)

  echo "Interpolating..."
  eval "echo \"$(cat pcf-prometheus-git/tasks/etc/local.yml)\"" > local.yml
  bosh-cli interpolate pcf-prometheus-manifest/prometheus.yml -l local.yml > manifest.yml
else
  echo "Interpolating..."
  eval "echo \"$(cat pcf-prometheus-git/tasks/etc/local.yml)\"" > local.yml
  bosh-cli interpolate pcf-prometheus-manifest/prometheus-no-route.yml -l local.yml > manifest.yml

fi


echo "Deploying..."

bosh -n deployment manifest.yml

bosh -n deploy --no-redact
