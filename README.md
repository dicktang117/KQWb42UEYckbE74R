# Full node blockchain

## 1. Description
In this git repository, I use **Crypto.org Mainnet** to build a BlockChain full node. The Terraform create an EC2 instance allowing SSH and ports 1317 & 26657 traffic in the same VPC, and invoke Ansible playbook to do the configuration.

## 2. Q & A
Q: Please briefly explain your system and why you are going to implement it like that.

A: It uses terraform to provison required resoureces, and passes the private IP to ansible as remote host. I want to keep all traffic inside the VPC to avoid any networking risk.


Q: Please state any assumption and limitation of the system implemented

A: User need to have an existed ansible+terraform EC2 in same VPC.


Q: How would you perform upgrade software deployed and minimise downtime?

A: Use an ansible playbook in different role(upgrade).


Q: How would you monitor this installation?

A: By cloudwatch. But disk utilization is necessary for blockchain, I will install node exporter additionally.


Q: How would you ensure security of this deployment

A: By the security group to limit the network traffic.


## 3. Pre-requisites
- AWS VPC 
- An EC2 installed with Ansible(>=v2.9.18) & Terraform(>=v0.15.0) in the same VPC
- Git installed in the VPC (for clone this repository)

## 4. Get started

Clone this repository to your EC2 instance with Ansible & Terraform.

```bash
# go to terraform folder
cd KQWb42UEYckbE74R/terraform
```

```bash
# init and plan
terraform init && terraform plan
```

Start implementation
```bash
terraform apply -auto-approve
```




