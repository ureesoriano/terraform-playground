terraform {
    backend "s3" {
        bucket = "terraform-playground-osoriano"
        key    = "production.tfstate"
        region = "eu-west-2"
    }
}
