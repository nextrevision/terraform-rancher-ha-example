#------------------------------------------#
# Elastic Load Balancer HTTP Configuration
#------------------------------------------#
resource "aws_elb" "rancher_ha_http" {
    count                       = "${1 - var.enable_https}"
    name                        = "${var.name_prefix}-elb"
    internal                    = false
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 30
    cross_zone_load_balancing   = true

    instances = ["${aws_instance.rancher_ha.*.id}"]
    subnets   = ["${aws_subnet.rancher_ha.*.id}"]

    security_groups = [
        "${aws_security_group.rancher_ha_elb.id}",
        "${aws_security_group.rancher_ha_elb_http.id}"
    ]

    listener {
        instance_port = 8080
        instance_protocol = "tcp"
        lb_port = 80
        lb_protocol = "tcp"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:8080/ping"
        interval = 30
    }

    tags {
        Name = "${var.name_prefix}-elb"
    }
}

resource "aws_proxy_protocol_policy" "http" {
    count          = "${1 - var.enable_https}"
    load_balancer  = "${aws_elb.rancher_ha_http.name}"
    instance_ports = ["80"]
}

resource "aws_security_group" "rancher_ha_elb_http" {
    count       = "${1 - var.enable_https}"
    name        = "${var.name_prefix}-elb-http"
    description = "Rancher HA Public HTTP Traffic"
    vpc_id      = "${aws_vpc.rancher_ha.id}"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
