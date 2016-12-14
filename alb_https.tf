#----------------------------------------------#
# Application Load Balancer HTTPS Configuration
#----------------------------------------------#
resource "aws_alb_listener" "rancher_ha" {
    count             = "${var.enable_https}"
    load_balancer_arn = "${aws_alb.rancher_ha.arn}"
    port              = "443"
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2015-05"
    certificate_arn   = "${aws_iam_server_certificate.rancher_ha.arn}"

    default_action {
        target_group_arn = "${aws_alb_target_group.rancher_ha.arn}"
        type             = "forward"
    }
}

resource "aws_iam_server_certificate" "rancher_ha" {
    count             = "${var.enable_https}"
    name              = "${var.name_prefix}-certificate"
    certificate_body  = "${file("${var.cert_body}")}"
    private_key       = "${file("${var.cert_private_key}")}"
    certificate_chain = "${file("${var.cert_chain}")}"
}

resource "aws_security_group_rule" "allow_https" {
    count             = "${var.enable_https}"
    type              = "ingress"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.rancher_ha_alb.id}"
}
