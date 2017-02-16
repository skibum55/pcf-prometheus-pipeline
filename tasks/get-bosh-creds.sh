#!/bin/bash
set -e

mkdir -p get-bosh-creds

chmod +x tool-om/om-linux

CURL="./tool-om/om-linux --target https://opsman.${pcf_ert_domain} -k \
  --username $pcf_opsman_admin_username \
  --password $pcf_opsman_admin_password \
  curl"

$CURL --path=/api/v0/security/root_ca_certificate | jq -r .root_ca_certificate_pem > get-bosh-creds/bosh-ca.pem

$CURL --path=/api/v0/deployed/director/credentials/director_credentials > creds.json

cat creds.json | jq -r .credential.value.identity > get-bosh-creds/bosh-username
cat creds.json | jq -r .credential.value.password > get-bosh-creds/bosh-pass
