#------------------------------------------#
# EC2 ASG Configuration
#------------------------------------------#
resource "aws_instance" "rancher_ha" {
    count                       = "${var.count}"
    ami                         = "${var.ami}"
    instance_type               = "${var.instance_type}"
    key_name                    = "${var.key_name}"
    user_data                   = "${data.template_file.install.rendered}"
    subnet_id                   = "${element(sort(aws_subnet.rancher_ha.*.id), count.index)}"

    vpc_security_group_ids = ["${aws_security_group.rancher_ha.id}"]

    tags {
        Name = "${var.tag_name}-${count.index}"
    }

    root_block_device {
        volume_size = "${var.root_volume_size}"
        delete_on_termination = true
    }
    depends_on = ["aws_rds_cluster_instance.rancher_ha"]
}

data "template_file" "install" {
    template = <<-EOF
                #cloud-config
                write_files:
                - content: |
                    #!/bin/bash
                    wait-for-docker
                    docker run -d --restart=unless-stopped \
                      -p 8080:8080 -p 9345:9345 \
                      rancher/server:$${rancher_version} \
                      --db-host $${db_host} \
                      --db-name $${db_name} \
                      --db-port $${db_port} \
                      --db-user $${db_user} \
                      --db-pass $${db_pass} \
                      --advertise-address $(ip route get 8.8.8.8 | awk '{print $NF;exit}')
                  path: /etc/rc.local
                  permissions: "0755"
                  owner: root
                EOF

    vars {
        rancher_version = "${var.rancher_version}"
        db_host         = "${aws_rds_cluster.rancher_ha.endpoint}"
        db_name         = "${aws_rds_cluster.rancher_ha.database_name}"
        db_port         = "${aws_rds_cluster.rancher_ha.port}"
        db_user         = "${var.db_user}"
        db_pass         = "${var.db_pass}"
    }
}

resource "aws_security_group" "rancher_ha" {
    name        = "${var.tag_name}-server"
    description = "Rancher HA Server Ports"
    vpc_id      = "${aws_vpc.rancher_ha.id}"

    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "tcp"
        self      = true
    }

    ingress {
        from_port = 0
        to_port   = 65535
        protocol  = "udp"
        self      = true
    }

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    ingress {
        from_port   = 9345
        to_port     = 9345
        protocol    = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
