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
resource "vault_policy" "github-user" {
  count = "${length(var.teams)}"

  name = "${element(var.teams, count.index)}"

  policy = <<EOT
path "/springernature/${element(var.teams, count.index)}/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
EOT

  depends_on = ["vault_mount.springernature"]
}

resource "vault_generic_secret" "team-policy" {
  count = "${length(var.teams)}"

  path = "auth/github/map/teams/${element(var.teams, count.index)}"

  data_json = <<EOT
{
  "value": "${element(var.teams, count.index)}"
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
