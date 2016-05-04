#------------------------------------------#
# Elastic Load Balancer Configuration
#------------------------------------------#
resource "aws_elb" "rancher_ha" {
    name                        = "${var.tag_name}-elb"
    internal                    = false
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 30
    cross_zone_load_balancing   = true

    subnets = [
        "${aws_subnet.rancher_ha_a.id}",
        "${aws_subnet.rancher_ha_b.id}",
        "${aws_subnet.rancher_ha_d.id}",
    ]

    security_groups = ["${aws_security_group.rancher_ha_elb.id}"]

    instances = [
        "${aws_instance.rancher_ha_a.id}",
        "${aws_instance.rancher_ha_b.id}",
        "${aws_instance.rancher_ha_d.id}"
    ]

    listener {
        instance_port = 80
        instance_protocol = "tcp"
        lb_port = 80
        lb_protocol = "tcp"
    }

    listener {
        instance_port = 443
        instance_protocol = "ssl"
        lb_port = 443
        lb_protocol = "ssl"
        ssl_certificate_id = "${aws_iam_server_certificate.rancher_ha.arn}"
    }

    listener {
        instance_port = 18080
        instance_protocol = "tcp"
        lb_port = 18080
        lb_protocol = "tcp"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "SSL:443"
        interval = 30
    }

    tags {
        Name = "${var.tag_name}-elb"
    }
}

resource "aws_iam_server_certificate" "rancher_ha" {
    name              = "${var.tag_name}-certificate"
    certificate_body  = "${file("${var.cert_body}")}"
    private_key       = "${file("${var.cert_private_key}")}"
    certificate_chain = "${file("${var.cert_chain}")}"
}

resource "aws_security_group" "rancher_ha_elb" {
    name        = "${var.tag_name}-elb-secgroup"
    description = "Rancher HA Public Ports"
    vpc_id      = "${aws_vpc.rancher_ha.id}"

    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "tcp"
        self      = true
    }

    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "udp"
        self      = true
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 18080
        to_port     = 18080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
