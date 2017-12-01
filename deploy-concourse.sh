DEPLOYMENT_PATH=~/deployments/concourse-deployment/cluster

yes | bosh update-cloud-config $DEPLOYMENT_PATH/cloud_configs/vbox.yml
yes | bosh deploy -d concourse $DEPLOYMENT_PATH/concourse.yml \
  -l $DEPLOYMENT_PATH/../versions.yml \
  -o $DEPLOYMENT_PATH/operations/static-web.yml \
  -o $DEPLOYMENT_PATH/operations/no-auth.yml \
  --vars-store credentials/concourse-creds.yml \
  --var web_ip=10.244.16.2 \
  --var external_url=http://10.244.16.2:8080 \
  --var network_name=concourse \
  --var web_vm_type=concourse \
  --var db_vm_type=concourse \
  --var db_persistent_disk_type=db \
  --var worker_vm_type=concourse
