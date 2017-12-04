DEPLOYMENT_PATH=~/deployments/vault-deployment
yes | bosh update-cloud-config cloud-configs/vault.yml \
  -v z1_gateway=10.244.16.1 \
  -v z1_range=10.244.16.0/30 \
  -v z1_static="[10.244.16.2]" \
  -v z2_gateway=10.244.17.1 \
  -v z2_range=10.244.17.0/24

yes | bosh deploy -d vault $DEPLOYMENT_PATH/manifests/vault.yml \
  --vars-store credentials/vault-creds.yml
