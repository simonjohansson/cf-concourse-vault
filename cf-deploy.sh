DEPLOYMENT_PATH=~/deployments/cf-deployment

yes | bosh update-cloud-config $DEPLOYMENT_PATH/iaas-support/bosh-lite/cloud-config.yml

yes | bosh deploy -d cf $DEPLOYMENT_PATH/cf-deployment.yml \
  -o $DEPLOYMENT_PATH/operations/bosh-lite.yml \
  -o $DEPLOYMENT_PATH/operations/use-compiled-releases.yml \
  --vars-store credentials/cf-creds.yml \
  -v system_domain=bosh-lite.com
