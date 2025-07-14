terraform {
  required_version = ">= 1.11.0, < 1.12.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.2"
    }
  }
}
