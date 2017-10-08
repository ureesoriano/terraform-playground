resource "aws_instance" "example" {
  ami           = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
  instance_type = "t2.nano"
}


resource "aws_key_pair" "acme" {
    key_name   = "acme"
    public_key = "${file("terraform.pub")}"
}

resource "aws_s3_bucket" "acme" {
    bucket = "acme-terraform-101-images"
    acl    = "public-read"
}

# Create a new load balancer
resource "aws_elb" "acme" {
  name               = "acme-elb"
  availability_zones = ["eu-west-2a", "eu-west-2b"]

  listener {
    instance_port     = 5000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:5000/"
    interval            = 30
  }
}

resource "aws_security_group" "acme_instances" {
  name        = "acme_instances"
  description = "Allow load balancer traffic and outbound"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = ["${aws_elb.acme.source_security_group_id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "acme1" {
    ami                         = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    key_name                    = "acme"
}

resource "aws_elb_attachment" "acme1" {
  elb      = "${aws_elb.acme.id}"
  instance = "${aws_instance.acme1.id}"
}

resource "aws_instance" "acme2" {
    ami                         = "ami-e1f2e185" // Ubuntu 16.04 LTS hvm:ebs-ssd
    instance_type               = "t2.micro"
    associate_public_ip_address = true
    key_name                    = "acme"
}

resource "aws_elb_attachment" "acme2" {
  elb      = "${aws_elb.acme.id}"
  instance = "${aws_instance.acme2.id}"
}

resource "aws_db_instance" "acme" {
  allocated_storage    = 5
  storage_type         = "standard"
  engine               = "mysql"
  engine_version       = "5.7.17"
  instance_class       = "db.t2.micro"
  name                 = "acme"
  username             = "acme"
  password             = "12345678"
  skip_final_snapshot  = true
}
