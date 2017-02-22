#!/bin/bash
set -e

bosh -n --ca-cert om-bosh-creds/bosh-ca.pem target `cat om-bosh-creds/director_ip`

BOSH_USERNAME=$(cat om-bosh-creds/bosh-username)
BOSH_PASSWORD=$(cat om-bosh-creds/bosh-pass)

echo "Logging in to BOSH..."
bosh login <<EOF 1>/dev/null
$BOSH_USERNAME
$BOSH_PASSWORD
EOF

echo "Uploading Prometheus Release..."
bosh -n upload release prometheus-release/prometheus-*.tgz

echo "Uploading Routing Release..."
bosh -n upload release https://bosh.io/d/github.com/cloudfoundry-incubator/cf-routing-release
