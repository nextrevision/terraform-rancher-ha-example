#------------------------------------------#
# Elastic Load Balancer Configuration
#------------------------------------------#
resource "aws_elb" "rancher_ha_http" {
    count    = "${1 - var.enable_https}"
    name     = "${var.name_prefix}-elb-http"
    internal = "${var.internal_elb}"

    listener {
        instance_port     = 8080
        instance_protocol = "tcp"
        lb_port           = 80
        lb_protocol       = "tcp"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        target              = "HTTP:8080/ping"
        interval            = 30
    }

    subnets         = ["${aws_subnet.rancher_ha.*.id}"]
    security_groups = ["${aws_security_group.rancher_ha_elb.id}"]
    instances       = ["${aws_instance.rancher_ha.*.id}"]

    idle_timeout                = 400
    cross_zone_load_balancing   = true
    connection_draining         = true
    connection_draining_timeout = 400

    tags {
        Name = "${var.name_prefix}-elb-http"
    }
}

resource "aws_proxy_protocol_policy" "rancher_ha_http_proxy_policy" {
    count          = "${1 - var.enable_https}"
    load_balancer  = "${aws_elb.rancher_ha_https.name}"
    instance_ports = ["80", "81", "8080"]
}

resource "aws_security_group_rule" "allow_http" {
    count             = "${1 - var.enable_https}"
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.rancher_ha_elb.id}"
}
