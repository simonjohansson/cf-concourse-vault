# Login
resource "null_resource" "login" {
  provisioner "local-exec" {
    command = "fly -t ci login -c http://10.244.16.2:8080"
  }
}

#
resource "null_resource" "create-team" {
  count = "${length(var.teams)}"

  provisioner "local-exec" {
    command = <<-EOF
      yes | fly -t ci set-team -n ${element(var.teams, count.index)}\
      --github-auth-client-id ${var.github_client_id} \
      --github-auth-client-secret ${var.github_client_secret} \
      --github-auth-team springernature/${element(var.teams, count.index)} EOF
  }

  depends_on = ["null_resource.login"]
}
