# Quickstart
## TLDR
Installs CF, Concourse and Vault in BOSH lite.

Start by deploying Bosh, upload stemcell and then ...

## Prerequisites
### Bosh V2
https://bosh.io/docs/cli-v2.html#install

### Git repos
```
mkdir ~/deployments
git clone https://github.com/cloudfoundry/bosh-deployment ~/deployments/bosh-deployment
# Use fork until these issues are merged
# https://github.com/concourse/concourse-deployment/pull/20
# https://github.com/concourse/concourse-deployment/pull/22
git clone -b issues https://github.com/simonjohansson/concourse-deployment.git ~/deployments/concourse-deployment
```

### Networking
`./add-route.sh`

### direnv
Used to set correct environment variables

https://github.com/direnv/direnv

## Bosh
### Deploy
`./bosh-deploy.sh`

### Stop Bosh VM
`./bosh-stop.sh`

### Start Bosh VM
`./bosh-start.sh`

### Uploading stemcell
`bosh upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.11-warden-boshlite-ubuntu-trusty-go_agent.tgz`

## Concourse
### deploy
`concourse-deploy.sh`

### Logging in
`fly -t ci login -c http://10.244.16.2:8080`

If you dont have fly ctl, you can download it from
```
for MacOS:
http://10.244.16.2:8080/api/v1/cli?arch=amd64&platform=darwin

for Linux:
http://10.244.16.2:8080/api/v1/cli?arch=amd64&platform=linux
```
