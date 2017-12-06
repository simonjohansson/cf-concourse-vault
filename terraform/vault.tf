# Mount
resource "vault_mount" "springernature" {
  path = "/springernature"
  type = "generic"
}

# GitHub auth
resource "vault_auth_backend" "github" {
  type = "github"
  depends_on = ["vault_mount.springernature"]
}

resource "vault_generic_secret" "github-org" {
  path = "auth/github/config"

  data_json = <<EOT
{
  "organization": "springernature"
}
EOT

  depends_on = ["vault_auth_backend.github"]
}

# Github User
resource "vault_policy" "engineering-enablement" {
  name = "engineering-enablement"

  policy = <<EOT
path "/springernature/engineering-enablement/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT

  depends_on = ["vault_mount.springernature"]
}

resource "vault_generic_secret" "engineering-enablement-policy" {
  path = "auth/github/map/teams/engineering-enablement"

  data_json = <<EOT
{
  "value": "engineering-enablement"
}
EOT

  depends_on = ["vault_auth_backend.github"]
}

# Concourse
resource "vault_policy" "concourse" {
  name = "concourse"

  policy = <<EOT
path "springernature/*" {
  capabilities =  ["read", "list"]
}
EOT

  depends_on = ["vault_mount.springernature"]
}
