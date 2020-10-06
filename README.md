[![alt text](https://coresolutions.ltd/media/core-solutions-82.png "Core Solutions")](https://coresolutions.ltd)

[![maintained by Core Solutions](https://img.shields.io/badge/maintained%20by-coresolutions.ltd-00607c.svg)](https://coresolutions.ltd)
[![GitHub tag](https://img.shields.io/github/v/tag/coresolutions-ltd/terraform-aws-ecs.svg?label=latest)](https://github.com/coresolutions-ltd/terraform-aws-ecs/releases)
[![Terraform Version](https://img.shields.io/badge/terraform-~%3E%200.12-623ce4.svg)](https://github.com/hashicorp/terraform/releases)
[![License](https://img.shields.io/badge/License-Apache%202.0-brightgreen.svg)](https://opensource.org/licenses/Apache-2.0)

# Elastic Container Service Terraform Module

A Terraform module to provison a fully working ECS cluster.

## Getting Started

```sh
module "basic" {
    source  = "coresolutions-ltd/ecs/aws"
    version = "~> 0.0.1"
}
```

More examples can be found [here](https://github.com/coresolutions-ltd/terraform-aws-ecs/tree/master/examples).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

managed_scaling block definition
