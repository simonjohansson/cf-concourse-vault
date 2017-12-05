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
Unseal Key 1: BBab5p0NJBj3XoQXvNIuZOPjCOSIUxeqwVPlf/kQ6IgO
Unseal Key 2: C7cxHESlY3WBWFTO5p+k0wWvFZcJ0+/rajCcGeokTUu+
Unseal Key 3: ptARX3gGfJInx3/b11VPNQGaa0rdy3lk99zzPK+jMHoR
Unseal Key 4: GglMh2j0dHt144SHYaTtiVgEyhRmqoM+CR3rHNpl8J2q
Unseal Key 5: +ttdJQ9GoSNsXBpn6FoZJBFhAQUAEIi26tYeFAYUo6qk
Initial Root Token: 6d9ca1e0-049c-9925-3b4b-e833a0a82fb3

...
...

$ vault unseal
paste "Unseal Key 1"
$ vault unseal
paste "Unseal Key 2"
$ vault unseal
paste "Unseal Key 3"
$ vault auth "Initial Root Token"
```

### setup for concourse
```
$ vault mount -path=/concourse -description="Secrets for concourse pipelines" generic
Successfully mounted 'generic' at '/concourse'!

$ cat << EOF > /tmp/concourse-policy.hcl
path "concourse/*" {
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

## Concourse
### deploy
`./concourse-deploy.sh`

### Logging in
`fly -t ci login -c http://10.244.16.2:8080`

### Setup a team
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
