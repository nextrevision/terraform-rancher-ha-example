#------------------------------------------#
# Elastic Load Balancer Common Configuration
#------------------------------------------#
resource "aws_security_group" "rancher_ha_elb" {
    name        = "${var.name_prefix}-elb-default"
    description = "Rancher HA ELB Common Traffic"
    vpc_id      = "${aws_vpc.rancher_ha.id}"
}

resource "aws_security_group_rule" "allow_all_self" {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    self              = true
    security_group_id = "${aws_security_group.rancher_ha_elb.id}"
}

resource "aws_security_group_rule" "allow_icmp" {
    type              = "ingress"
    from_port         = 0
    to_port           = 0
    protocol          = "icmp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.rancher_ha_elb.id}"
}

resource "aws_security_group_rule" "allow_all_out" {
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.rancher_ha_elb.id}"
}
