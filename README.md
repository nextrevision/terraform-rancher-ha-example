# terraform-rancher-ha-example
Terraform files for deploying a Rancher HA cluster in AWS

> Update: since v1.2.0 simplified the HA deployment process, master reflects the latest way to deploy Rancher HA. If you are looking for the previous code, it is tagged under [v1.0.0](https://github.com/nextrevision/terraform-rancher-ha-example/tree/v1.0.0).

These files are meant as a companion to the following blog post:

[https://thisendout.com/2016/12/10/update-deploying-rancher-in-production-aws-terraform-rancheros/](https://thisendout.com/2016/12/10/update-deploying-rancher-in-production-aws-terraform-rancheros/)

## Usage

Clone this repo:

```
git clone https://github.com/nextrevision/terraform-rancher-ha-example
cd terraform-rancher-ha-example
```

Edit the `terraform.tfvars` file:

```
# AWS key for the instances
key_name = "rancher-example"

# RDS database password
db_pass = "rancherdbpass"

# To enable SSL termination on the ELBs, uncomment the lines below.
#enable_https = true
#cert_body = "certs/cert1.pem"              # Signed Certificate
#cert_private_key = "certs/privkey1.pem"    # Certificate Private Key
#cert_chain = "certs/chain1.pem"            # CA chain
```

To create the cluster:

```
terraform apply
```

To destroy:

```
terraform destroy
```

## Variables

### AWS Infrastructure
* **region**: AWS region (default: `us-east-1`)
* **count**: number of HA servers to deploy (default: `3`)
* **name_prefix**: prefix for all AWS resource names (default: `rancher-ha`)
* **ami**: instance AMI ID (default: `ami-dfdff3c8`; RancherOS in us-east-1)
* **key_name**: SSH key name in your AWS account for AWS instances (required)
* **instance_type**: AWS instance type (default: `t2.large` for RAM requirement)
* **root_volume_size**: size in GB of the instance root volume (default: `16`)
* **vpc_cidr**: subnet in CIDR format to assign to the VPC (default: `192.168.199.0/24`)
* **subnet_cidrs**: list of subnet ranges (3 required) (default: `["192.168.199.0/26", "192.168.199.64/26", "192.168.199.128/26"`)
* **availability_zones**: AZs for placing instances and subnets (may change based on your account's availability) (default: `["us-east-1a", "us-east-1b", "us-east-1d"]`)

> Note: if you use an AMI other than RancherOS, the automatic launching of the Rancher server container will not work. You will need to update the user-data template according to the needs of your AMI.

### Database
* **db_name**: name of the RDS DB (default: `rancher`)
* **db_user**: username used to connect to the RDS database (default: `rancher`)
* **db_pass**: password used to connect to the RDS database (required)

### SSL
* **enable_https**: enable HTTPS termination on the loadbalancer (default: `false`)
* **cert_body**: required if `enable_https` is set to `true`
* **cert_private_key**: required if `enable_https` is set to `true`
* **cert_chain**: required if `enable_https` is set to `true`

### Rancher
* **rancher_version**: Rancher version to deploy (default: `stable`)
