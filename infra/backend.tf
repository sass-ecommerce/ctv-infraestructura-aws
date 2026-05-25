terraform {
  backend "s3" {
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
