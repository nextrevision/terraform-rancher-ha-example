#----------------------------------------------#
# Application Load Balancer HTTPS Configuration
#----------------------------------------------#
resource "aws_alb" "rancher_ha" {
    count                      = "${var.enable_https}"
    name                       = "${var.name_prefix}-alb-https"
    internal                   = false
    enable_deletion_protection = true

    subnets = ["${aws_subnet.rancher_ha.*.id}"]

    security_groups = [
        "${aws_security_group.rancher_ha_elb.id}",
        "${aws_security_group.rancher_ha_alb_https.id}"
    ]
}

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

resource "aws_alb_target_group" "rancher_ha" {
    count    = "${var.enable_https}"
    name     = "${var.name_prefix}-target-group"
    port     = 8080
    protocol = "HTTP"
    vpc_id   = "${aws_vpc.rancher_ha.id}"

    health_check {
        path     = "/ping"
        protocol = "HTTP"
    }
}

# TODO: figure out how to optionally enable this attachment based on var.enable_https
resource "aws_alb_target_group_attachment" "rancher_ha" {
    count            = "${length(aws_instance.rancher_ha.*.id)}"
    target_group_arn = "${aws_alb_target_group.rancher_ha.arn}"
    target_id        = "${element(aws_instance.rancher_ha_a.*.id, count.index)}"
    port             = 8080
}

resource "aws_iam_server_certificate" "rancher_ha" {
    count             = "${var.enable_https}"
    name              = "${var.name_prefix}-certificate"
    certificate_body  = "${file("${var.cert_body}")}"
    private_key       = "${file("${var.cert_private_key}")}"
    certificate_chain = "${file("${var.cert_chain}")}"
}

resource "aws_security_group" "rancher_ha_alb_https" {
    count       = "${var.enable_https}"
    name        = "${var.name_prefix}-alb-https"
    description = "Rancher HA Public HTTPS Traffic"
    vpc_id      = "${aws_vpc.rancher_ha.id}"

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
