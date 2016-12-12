#------------------------------------------#
# AWS VPC Configuration
#------------------------------------------#
resource "aws_vpc" "rancher_ha" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags {
        Name = "${var.name_prefix}-vpc"
    }
}

resource "aws_subnet" "rancher_ha" {
    count                   = "3"
    vpc_id                  = "${aws_vpc.rancher_ha.id}"
    cidr_block              = "${element(var.subnet_cidrs, count.index)}"
    availability_zone       = "${element(var.availability_zones, count.index)}"
    map_public_ip_on_launch = true
    tags {
      Name = "${var.name_prefix}-subnet-${count.index}"
    }
}

resource "aws_internet_gateway" "rancher_ha" {
    vpc_id     = "${aws_vpc.rancher_ha.id}"
    depends_on = ["aws_vpc.rancher_ha"]
    tags {
      Name = "${var.name_prefix}-igw"
    }
}

resource "aws_route" "rancher_ha" {
    route_table_id         = "${aws_vpc.rancher_ha.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = "${aws_internet_gateway.rancher_ha.id}"
    depends_on             = ["aws_vpc.rancher_ha", "aws_internet_gateway.rancher_ha"]
}

resource "aws_vpc_dhcp_options" "rancher_dns" {
    domain_name         = "ec2.internal"
    domain_name_servers = ["169.254.169.253", "AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "rancher_dns" {
    vpc_id          = "${aws_vpc.rancher_ha.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.rancher_dns.id}"
}
