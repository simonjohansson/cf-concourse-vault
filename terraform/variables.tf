variable "github_client_id" {
  default = ""
}

variable "github_client_secret" {
  default = ""
}


variable "teams" {
  type = "list"
  default = [
    "engineering-enablement",
    "japan"
  ]
}
