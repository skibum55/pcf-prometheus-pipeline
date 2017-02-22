#!/bin/bash
set -e

bosh -n --ca-cert om-bosh-creds/bosh-ca.pem target `cat om-bosh-creds/director_ip`

BOSH_USERNAME=$(cat om-bosh-creds/bosh-username)
BOSH_PASSWORD=$(cat om-bosh-creds/bosh-pass)

bosh login <<EOF 1>/dev/null
$BOSH_USERNAME
$BOSH_PASSWORD
EOF

eval "echo \"$(cat pcf-prometheus-git/tasks/etc/local.yml)\""
