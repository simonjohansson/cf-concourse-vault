# Quickstart

## Prerequisites
### Bosh V2
https://bosh.io/docs/cli-v2.html#install

### Git repos
```
mkdir ~/deployments
git clone https://github.com/cloudfoundry/bosh-deployment ~/deployments/bosh-deployment
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
