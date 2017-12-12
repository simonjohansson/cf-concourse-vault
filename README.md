# Quickstart
## TLDR
Installs CF, Concourse and Vault in BOSH lite. And enables GitHub auth for Vault and Concourse.

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
[Direnv](https://github.com/direnv/direnv) is used to set correct environment variables

### Terraform
[Terraform](https://www.terraform.io/downloads.html) is used setup all the required stuff in Vault and setting up a GitHub auth team in Concourse.

### Vault
[HashiCorp Vault](https://www.vaultproject.io/downloads.html)

## Run list
### 0
Allow direnv to set environment variables.

`direnv allow`

### 1
Deploy CF, Vault and Concourse
```
# First we need us a Bosh
$ ./bosh-deploy.sh

# Then we upload the base image all the containers will use
$ bosh upload-stemcell https://s3.amazonaws.com/bosh-core-stemcells/warden/bosh-stemcell-3468.11-warden-boshlite-ubuntu-trusty-go_agent.tgz

# Next we install Cloud Foundry
$ ./cf-deploy.sh

# Then we install Vault
$ ./vault-deploy.sh

# And finally Concourse
$ ./concourse-deploy.sh
```

### 2
Some manual steps needed. :/

#### 2.1
We need to do initial Vault init.

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

$ vault unseal USEAL_KEY_1
$ vault unseal USEAL_KEY_2
$ vault unseal USEAL_KEY_3
$ vault auth INITIAL_ROOT_TOKEN
```

#### 2.2
Add client_id and client_secret as variables for Terraform, so it can configure GitHub -> Concourse auth
These vars are in `terraform/variables.tf`

### 2.3
Make sure you have the fly cli on your path, this is needed by terraform in the next step.
```
for MacOS:
http://10.244.16.2:8080/api/v1/cli?arch=amd64&platform=darwin

for Linux:
http://10.244.16.2:8080/api/v1/cli?arch=amd64&platform=linux
```

Don't continue if you cannot execute `fly` from the CLI!

### 2.4
Terraform sets up GitHub auth and policies for Vault, and configures teams in Concourse.

```
$ cd terraform
$ terraform init
$ terraform apply # This sets up all the required stuff in Vault.
```

### 2.5
Create a vault token for Concourse and update the concourse deployment.

```
$ vault token-create --policy=concourse -period="60000h" -format=json
{
....
	"auth": {
		"client_token": "150a8e7f-8391-b2ca-6841-22f5459417b9", <---- THIS IS IMPORTANT
		....
	}
}
```

Add above client_token at the bottom of `credentials/concourse-creds.yml` in
`vault.auth.client_token`

### 2.6
Deploy concourse again, to use the Vault key.
```
./concourse-deploy.sh
```

### Create a space
```
cf create-space dev
```

### Target it
```
cf target -o system -s dev
```
