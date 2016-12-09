#------------------------------------------#
# Elastic Load Balancer HTTPS Configuration
#------------------------------------------#
resource "aws_elb" "rancher_ha_https" {
    count                       = "${var.enable_https}"
    name                        = "${var.tag_name}-elb-https"
    internal                    = false
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 30
    cross_zone_load_balancing   = true

    instances = ["${aws_instance.rancher_ha.*.id}"]
    subnets = ["${aws_subnet.rancher_ha.*.id}"]

    security_groups = [
        "${aws_security_group.rancher_ha_elb.id}",
        "${aws_security_group.rancher_ha_elb_https.id}"
    ]

    listener {
        instance_port = 8080
        instance_protocol = "tcp"
        lb_port = 443
        lb_protocol = "ssl"
        ssl_certificate_id = "${aws_iam_server_certificate.rancher_ha.arn}"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:8080/ping"
        interval = 30
    }

    tags {
        Name = "${var.tag_name}-elb-https"
    }
}

resource "aws_proxy_protocol_policy" "https" {
    count          = "${var.enable_https}"
    load_balancer  = "${aws_elb.rancher_ha_https.name}"
    instance_ports = ["443"]
}

resource "aws_iam_server_certificate" "rancher_ha" {
    count             = "${var.enable_https}"
    name              = "${var.tag_name}-certificate"
    certificate_body  = "${file("${var.cert_body}")}"
    private_key       = "${file("${var.cert_private_key}")}"
    certificate_chain = "${file("${var.cert_chain}")}"
}

resource "aws_security_group" "rancher_ha_elb_https" {
    count       = "${var.enable_https}"
    name        = "${var.tag_name}-elb-https"
    description = "Rancher HA Public HTTPS Traffic"
    vpc_id      = "${aws_vpc.rancher_ha.id}"

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
