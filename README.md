# Quickstart
## TLDR
Installs CF, Concourse and Vault in BOSH lite.

## Runlist
* Deploy BOSH
* Upload stemcell
* Deploy and initialise Vault
* Setup Vault for Concourse
* Deploy concourse

## Prerequisites
### Bosh V2
https://bosh.io/docs/cli-v2.html#install

### Git repos
```
mkdir ~/deployments
git clone https://github.com/cloudfoundry/bosh-deployment ~/deployments/bosh-deployment
git clone git@github.com:cloudfoundry-community/vault-boshrelease.git ~/deployments/vault-deployment
git clone https://github.com/cloudfoundry/cf-deployment.git ~/deployments/cf-deployment
# Use fork until these issues are merged
# https://github.com/concourse/concourse-deployment/pull/23
git clone -b configurable-network https://github.com/simonjohansson/concourse-deployment.git ~/deployments/concourse-deployment

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

## vault
### deploy
`./vault-deploy.sh`

### initialize
```
$ vault init
Unseal Key 1: USEAL_KEY_1
Unseal Key 2: USEAL_KEY_2
Unseal Key 3: USEAL_KEY_3
Unseal Key 4: USEAL_KEY_4
Unseal Key 5: USEAL_KEY_5
Initial Root Token: INITIAL_ROOT_TOKEN

...
...

$ vault unseal
paste USEAL_KEY_1
$ vault unseal
paste USEAL_KEY_2
$ vault unseal
paste USEAL_KEY_3
$ vault auth INITIAL_ROOT_TOKEN
```

### setup for concourse
```
$ vault mount -path=/springernature -description="Secrets" generic
Successfully mounted 'generic' at '/springernature'!

$ cat << EOF > /tmp/concourse-policy.hcl
path "springernature/*" {
  policy = "read"
  capabilities =  ["read", "list"]
}
EOF

$ vault policy-write concourse-policy /tmp/policy.hcl

$ vault token-create --policy=concourse-policy -period="60000h" -format=json
{
....
	"auth": {
		"client_token": "150a8e7f-8391-b2ca-6841-22f5459417b9",
		....
	}
}

# PUT value of client_token from above at the bottom of credentials/concourse-creds.yml in vault.auth.client_token
```

### GitHub auth
```
$ vault auth-enable github
$ vault write auth/github/config organization=springernature
$ cat << EOF > /tmp/engineering-enablement-policy.hcl
path "springernature/engineering-enablement/*" {
  capabilities =  ["create", "read", "update", "delete", "list"]
}
EOF
$ vault policy-write engineering-enablement-policy /tmp/engineering-enablement-policy.hcl
$ vault write auth/github/map/teams/engineering-enablement value=engineering-enablement-policy
```

## Concourse
### deploy
`./concourse-deploy.sh`

### Logging in
`fly -t ci login -c http://10.244.16.2:8080`

### Setup a team with GitHub auth
```
fly -t ci set-team -n engineering-enablement \
    --github-auth-client-id CLIENT_ID \
    --github-auth-client-secret CLIENT_SECRET \
    --github-auth-team springernature/engineering-enablement
```

If you dont have fly ctl, you can download it from
```
for MacOS:
http://10.244.16.2:8080/api/v1/cli?arch=amd64&platform=darwin

for Linux:
http://10.244.16.2:8080/api/v1/cli?arch=amd64&platform=linux
```

## Cloud Foundry
### deploy
`./cf-deploy.sh`

Grab some coffee.

### Log in
```
cf api https://api.bosh-lite.com --skip-ssl-validation
cf auth admin $(bosh int credentials/cf-creds.yml --path /cf_admin_password)
```
