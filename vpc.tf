#------------------------------------------#
# VPC Configuration
#------------------------------------------#
resource "aws_vpc" "rancher_ha" {
    cidr_block           = "192.168.99.0/24"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags {
        Name = "${var.tag_name}-vpc"
    }
}

resource "aws_subnet" "rancher_ha_a" {
    vpc_id                  = "${aws_vpc.rancher_ha.id}"
    cidr_block              = "192.168.99.0/25"
    availability_zone       = "${var.region}a"
    map_public_ip_on_launch = true
    tags {
      Name = "${var.tag_name}-subnet-a"
    }
}

resource "aws_subnet" "rancher_ha_b" {
    vpc_id                  = "${aws_vpc.rancher_ha.id}"
    cidr_block              = "192.168.99.128/26"
    availability_zone       = "${var.region}b"
    map_public_ip_on_launch = true
    tags {
      Name = "${var.tag_name}-subnet-b"
    }
}

resource "aws_subnet" "rancher_ha_d" {
    vpc_id                  = "${aws_vpc.rancher_ha.id}"
    cidr_block              = "192.168.99.192/26"
    availability_zone       = "${var.region}d"
    map_public_ip_on_launch = true
    tags {
      Name = "${var.tag_name}-subnet-d"
    }
}

resource "aws_internet_gateway" "rancher_ha" {
    vpc_id     = "${aws_vpc.rancher_ha.id}"
    depends_on = ["aws_vpc.rancher_ha"]
    tags {
      Name = "${var.tag_name}-igw"
    }
}

resource "aws_route" "rancher_ha" {
    route_table_id         = "${aws_vpc.rancher_ha.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = "${aws_internet_gateway.rancher_ha.id}"
    depends_on             = ["aws_vpc.rancher_ha", "aws_internet_gateway.rancher_ha"]
}
