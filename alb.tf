#------------------------------------------#
# Application Load Balancer Configuration
#------------------------------------------#
resource "aws_alb" "rancher_ha" {
    name                       = "${var.name_prefix}-alb"
    internal                   = false
    enable_deletion_protection = false

    subnets = ["${aws_subnet.rancher_ha.*.id}"]
    security_groups = ["${aws_security_group.rancher_ha_alb.id}"]
}

resource "aws_alb_target_group" "rancher_ha" {
    name     = "${var.name_prefix}-tg"
    port     = 8080
    protocol = "HTTP"
    vpc_id   = "${aws_vpc.rancher_ha.id}"

    health_check {
        path     = "/ping"
        protocol = "HTTP"
    }
}

resource "aws_alb_target_group_attachment" "rancher_ha" {
    count            = "${var.count}"
    target_group_arn = "${aws_alb_target_group.rancher_ha.arn}"
    target_id        = "${element(aws_instance.rancher_ha.*.id, count.index)}"
    port             = 8080
}

resource "aws_security_group" "rancher_ha_alb" {
    name        = "${var.name_prefix}-alb-default"
    description = "Rancher HA ALB Common Traffic"
    vpc_id      = "${aws_vpc.rancher_ha.id}"
}

resource "aws_security_group_rule" "allow_all_self" {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    self              = true
    security_group_id = "${aws_security_group.rancher_ha_alb.id}"
}

resource "aws_security_group_rule" "allow_icmp" {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "icmp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.rancher_ha_alb.id}"
}

resource "aws_security_group_rule" "allow_all_out" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.rancher_ha_alb.id}"
}
