provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

resource "aws_instance" "example" {
  ami           = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
  instance_type = "t2.nano"
}
