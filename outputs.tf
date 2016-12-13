#------------------------------------------#
# AWS Outputs
#------------------------------------------#
output "alb_dns" {
    value = "${aws_alb.rancher_ha.dns_name}"
}
