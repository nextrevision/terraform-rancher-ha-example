#------------------------------------------#
# AWS Outputs
#------------------------------------------#
output "instances" {
    value = ["${aws_instance.rancher_ha.*.id}"]
}

output "elb_http_dns" {
    value = "${aws_elb.rancher_ha_http.dns_name}"
}

output "elb_https_dns" {
    value = "${aws_elb.rancher_ha_https.dns_name}"
}

output "rds_dns" {
    value = "${aws_rds_cluster.rancher_ha.endpoint}"
}
