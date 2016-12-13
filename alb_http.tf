#----------------------------------------------#
# Application Load Balancer HTTP Configuration
#----------------------------------------------#
resource "aws_alb_listener" "rancher_ha_http" {
    count             = "${1 - var.enable_https}"
    load_balancer_arn = "${aws_alb.rancher_ha.arn}"
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = "${aws_alb_target_group.rancher_ha.arn}"
        type             = "forward"
    }
}

resource "aws_security_group_rule" "allow_http" {
    count             = "${1 - var.enable_https}"
    type              = "ingress"
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.rancher_ha_alb.id}"
}
