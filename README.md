# terraform-rancher-ha-example
Terraform files for deploying a Rancher HA cluster in AWS

These files are meant as a companion to the following blog post:

[https://thisendout.com/2016/05/04/deploying-rancher-with-ha-using-rancheros-aws-terraform-letsencrypt/](https://thisendout.com/2016/05/04/deploying-rancher-with-ha-using-rancheros-aws-terraform-letsencrypt/)

## Usage

Clone this repo:

```
git clone https://github.com/nextrevision/terraform-rancher-ha-example
cd terraform-rancher-ha-example
```

Create a `terraform.tfvars` file with the following contents:

```
# aws access and secret keys
# could also be exported as ENV vars, but included here for simplicity
access_key = ""
secret_key = ""

# certificate paths
# after receiving certificates from Let's Encrypt, I placed
# them in ./certs. modify these values with the paths to your
# certificates.
cert_body = "./certs/cert1.pem"
cert_private_key = "./certs/privkey1.pem"
cert_chain = "./certs/chain1.pem"

# database password rancher uses to connect to RDS
db_password = "rancherdbpass"
```

To create the cluster:

```
terraform apply
```

To destroy:

```
terraform destroy
```

These files are only meant to create the infrastructure needed to run Rancher with HA in AWS. Configuring and deploying Rancher will need to be done independently (see blog post for details).
