#------------------------------------------#
# AWS Environment Values
#------------------------------------------#
variable "region" {
    default     = "us-east-1"
    description = "The region of AWS, for AMI lookups"
}

variable "count" {
    default     = "3"
    description = "Number of HA servers to deploy"
}

variable "ami" {
    default     = "ami-dfdff3c8"
    #default     = "ami-4d795c5a"
    description = "Instance AMI ID"
}

variable "key_name" {
    description = "SSH key name in your AWS account for AWS instances"
}

variable "instance_type" {
    default     = "t2.large" # RAM Requirements >= 8gb
    description = "AWS Instance type"
}

variable "tag_name" {
    default     = "rancher-ha"
    description = "Prefix for Name tag the servers"
}

variable "db_name" {
    default     = "rancher"
    description = "Name of the RDS DB"
}

variable "db_user" {
    default     = "rancher"
    description = "Username used to connect to the RDS database"
}

variable "db_pass" {
    description = "Password used to connect to the RDS database"
}

variable "pre_install_script" {
    default     = ""
    description = "Script to run before running the Docker command to start Rancher"
}

variable "enable_https" {
		default     = false
    description = "Enable HTTPS termination on the loadbalancer"
}

variable "root_volume_size" {
    default     = "16"
    description = "Size in GB of the root volume for instances"
}

variable "rancher_version" {
    default     = "latest"
    description = "Rancher version to deploy"
}

variable "cert_body" {
    default = ""
}

variable "cert_private_key" {
    default = ""
}

variable "cert_chain" {
    default = ""
}

variable "vpc_cidr" {
    default     = "192.168.199.0/24"
    description = "Subnet in CIDR format to assign to VPC"
}

variable "subnet_cidrs" {
    default     = ["192.168.199.0/26", "192.168.199.64/26", "192.168.199.128/26"]
    description = "Subnet ranges (requires 3 entries)"
}

variable "availability_zones" {
    default     = ["us-east-1a", "us-east-1b", "us-east-1d"]
    description = "Availability zones to place subnets"
}
