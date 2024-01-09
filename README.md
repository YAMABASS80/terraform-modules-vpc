# VPC Overview


# Parameters
|  Name  |  Type  | Description  |
| ---- | ---- | ---- |
|  vpc_cidr_block  |  string  | VPC CIDR range  |
|  vpc_name  |  string  | VPC tag name  |

# Outputs
|  Name  |  Type  | Description  |
| ---- | ---- | ---- |
|  vpc_id  |  string  | VPC ID  |
|  vpc_cidr  |  string  | VPC CIDR  |
|  public_subnet_1_id  |  string  | Public Subnet 1 ID  |
|  public_subnet_2_id  |  string  | Public Subnet 2 ID  |
|  private_subnet_1_id |  string  | Private Subnet 1 ID  |
|  private_subnet_2_id  |  string  | Private Subnet 1 ID  |
|  public_subnet_1_route_table_id  |  string  | Public Subnet 1 Route Table ID  |
|  public_subnet_2_route_table_id  |  string  | Public Subnet 1 Route Table ID  |
|  private_subnet_1_route_table_id |  string  | Private Subnet 1 Route Table ID |
|  private_subnet_1_route_table_id |  string  | Private Subnet 2 Route Table ID  |

# Usage

In your main.tf file, you can just write as below.
Please note that `ref=<>` is refering to the commit tag on this repo.

```hcl
module "network" {
  source         = "git@github.com:YAMABASS80/terraform-modules-vpc.git?ref=1.0.3"
  vpc_cidr_block = var.vpc_cidr_block
}
```

