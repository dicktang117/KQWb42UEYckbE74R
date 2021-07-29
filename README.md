# Full node blockchain

## 1. Description
In this git repository, I use **Crypto.org Mainnet** to build a BlockChain full node. The Terraform create an EC2 instance allowing SSH and ports 1317 & 26657 traffic in the same VPC, and invoke Ansible playbook to do the configuration.

## 2. Q & A
**Q: Please briefly explain your system and why you are going to implement it like that.**

A: It uses terraform to provison required resoureces, and passes the private IP to ansible as remote host. I want to keep all traffic inside the VPC to avoid any networking risk.


**Q: Please state any assumption and limitation of the system implemented**

A: User need to have an existed ansible+terraform EC2 in same VPC. The instance type is not suitable for a fullnode being and the storage size is too small to collect all historical data. (cut cost for my own aws account:))

**Q: How would you perform upgrade software deployed and minimise downtime?**

A: Use an ansible upgrade playbook, and update the ansible variable before execution.


**Q: How would you monitor this installation?**

A: By cloudwatch. But disk utilization is necessary for blockchain, I will install node exporter additionally.


**Q: How would you ensure security of this deployment?**

A: By the security group to limit the network traffic.


## 3. Pre-requisites
- AWS VPC 
- An EC2 installed with Ansible(>=v2.9.18), Terraform(>=v0.15.0) & AWS CLI in the same VPC
- Git installed in the EC2 (for clone this repository)

## 4. Get started

First, clone this repository to your EC2 instance with Ansible & Terraform:

```bash
# go to terraform folder
cd KQWb42UEYckbE74R/terraform
```

Setup your environment including aws credentials, vpc id, subnet id and key pair name:

```bash
# setup default AWS CLI profile
aws configure

# edit terraform variables for environment setting
### !!! Please update all variables values for fitting your environment.!!!
vi terraform.tfvars
```

```bash
# init and plan
terraform init && terraform plan
```

Start implementation
```bash
terraform apply -auto-approve
```

## 5. Validate Results
```bash
# go to terraform folder
cd KQWb42UEYckbE74R/terraform
```

```bash
# ssh to full node instance
sudo ssh -i full_node.pem ec2-user@{FullNodePrivateIP}
```

```bash
# check the status of chain-maind services
systemctl status chain-maind -l

## Besides, the APIs traffic ports(26657&1317) are able to connected in same VPC network. 
### API reference: https://crypto.org/docs/resources/blocks-and-transactions.html#common-apis-2
```

## 6. Upgrade
Upgrade mainnet blockchain from v1.x to v2.x

```bash
# go to ansible folder
cd KQWb42UEYckbE74R/ansible
```

```bash
# edit the upgrade git url is necessary in ansible's variable file
vi vars\variable.yml
# then edit the "upgrade_url" value
```

```bash
# execute ansible upgrade playbook
ansible-playbook upgrade.yml
```

## 7. Clean up all resources

```bash
# go to terraform folder
cd KQWb42UEYckbE74R/terraform

# destroy the terraform state
terraform destroy

## type "yes" if asking
```


