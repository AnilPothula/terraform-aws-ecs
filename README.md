[![alt text](https://coresolutions.ltd/media/core-solutions-82.png "Core Solutions")](https://coresolutions.ltd)

[![maintained by Core Solutions](https://img.shields.io/badge/maintained%20by-coresolutions.ltd-00607c.svg)](https://coresolutions.ltd)
[![GitHub tag](https://img.shields.io/github/v/tag/coresolutions-ltd/terraform-aws-ecs.svg?label=latest)](https://github.com/coresolutions-ltd/terraform-aws-ecs/releases)
[![Terraform Version](https://img.shields.io/badge/terraform-~%3E%200.12-623ce4.svg)](https://github.com/hashicorp/terraform/releases)
[![License](https://img.shields.io/badge/License-Apache%202.0-brightgreen.svg)](https://opensource.org/licenses/Apache-2.0)

# Elastic Container Service Terraform Module

A Terraform module to provison all apects of ECS with minimal configuraiton.

## Getting Started

```sh
module "getting_started" {
  source  = "coresolutions-ltd/ecs/aws"

  name = "Example"

  create_cluster                 = true
  create_services                = true
  create_capacity_provider       = true
  cp_instance_type               = "t3.nano"
  cp_min_size                    = 1
  cp_desired_capacity            = 1
  cp_max_size                    = 1
  cp_associate_public_ip_address = true
  cp_security_group_ids          = [aws_security_group.sg.id]
  cp_vpc_zone_identifier         = data.aws_subnet_ids.public.ids

  tasks = [{
    family                = "example"
    container_definitions = file("task.json")
    desired_count         = 1
  }]
}

```

More examples can be found [here](https://github.com/coresolutions-ltd/terraform-aws-ecs/tree/master/examples).


## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| random | ~> 2.0 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| capacity\_providers | List of short names for one or more capacity providers to associate with the cluster, Valid values also include `FARGATE` and `FARGATE_SPOT` | `list` | `[]` | no |
| container\_insights | Enable container insights | `bool` | `false` | no |
| cp\_associate\_public\_ip\_address | Associate a public IP address with the capacity provider network interface | `bool` | `false` | no |
| cp\_desired\_capacity | Desired capacity for the the Auto Scaling group capacity provider | `number` | `1` | no |
| cp\_instance\_type | The instance type used by the Auto Scaling group capacity provider | `string` | `"t3.micro"` | no |
| cp\_managed\_scaling | Managed scaling configuration for the capacity provider ASG | `map` | `{}` | no |
| cp\_managed\_termination\_protection | Enables or disables container-aware termination of instances in the auto scaling group when scale-in happens. Valid values are `ENABLED` and `DISABLED` | `string` | `"DISABLED"` | no |
| cp\_max\_size | Max size for the the Auto Scaling group capacity provider | `number` | `3` | no |
| cp\_min\_size | Min size for the the Auto Scaling group capacity provider | `number` | `1` | no |
| cp\_security\_group\_ids | A list of security group IDs to associate the capacity provide with | `list(string)` | `[]` | no |
| cp\_spot | Enable spot instances for the capacity provider ASG | `bool` | `false` | no |
| cp\_spot\_max\_price | Max price for the capacity provider ASG spot instances | `number` | `null` | no |
| cp\_vpc\_zone\_identifier | A list of subnet IDs to launch EC2 resources in | `list(string)` | `[]` | no |
| create\_capacity\_provider | Create an ECS cluster capacity provider and associated ASG | `bool` | `false` | no |
| create\_cluster | Create the ECS cluster | `bool` | `false` | no |
| create\_services | Create a service for each task specified | `bool` | `false` | no |
| default\_capacity\_provider\_strategies | The default capacity provider strategies to be used by the cluster, strategies cannot contain a mix of capacity providers using Auto Scaling groups and Fargate providers | `list` | `[]` | no |
| name | Name value for resources | `string` | `null` | no |
| services\_cluster | ARN of an existing ECS cluster for the services, if omitted and create\_cluster is true the new cluster will be used | `string` | `null` | no |
| tags | Resource tags | `map(string)` | `{}` | no |
| tasks | Tasks definitions to be created, values are used to create tasks and accompanying services | `list(object)` | `[]` | no |


### Objects in the **default_capacity_provider_strategies** list support the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| capacity\_provider | The short name of the capacity provider, can also be `FARGATE` or `FARGATE_SPOT` | `string` | `null` | yes |
| weight | The relative percentage of the total number of launched tasks that should use the specified capacity provider. | `number` | `null` | no |
| base | The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined. | `number` | `null` | no |

### *Example:*

```
default_capacity_provider_strategies = [{
      capacity_provider = "FARGATE"
      weight            = 60
      base              = 1
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 40
    }]
```


### The **cp_managed_scaling** object supports the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| maximum\_scaling\_step\_size | The maximum step adjustment size. A number between 1 and 10,000 | `number` | `null` | no |
| minimum\_scaling\_step\_size | The minimum step adjustment size. A number between 1 and 10,000 | `number` | `null` | no |
| status | Whether auto scaling is managed by ECS. Valid values are `ENABLED` and `DISABLED` | `string` | `null` | no |
| target\_capacity | The target utilization for the capacity provider. A number between 1 and 100 | `number` | `null` | no |


### Objects in the **tasks** list support the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| family | A unique name for your task definition. | `string` | `null` | yes |
| container\_definitions | A list of valid container definitions provided as a single valid JSON document. | `list` | `null` | yes |
| task\_role\_arn | The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services. | `string` | `null` | no |
| execution\_role\_arn | The Amazon Resource Name (ARN) of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. | `string` | `null` | no |
| network\_mode | The Docker networking mode to use for the containers in the task. The valid values are `none` `bridge` `awsvpc` and `host` | `string` | `null` | no |
| ipc\_mode | The IPC resource namespace to be used for the containers in the task The valid values are `host` `task` and `none` | `string` | `null` | no |
| pid\_mode | The process namespace to use for the containers in the task. The valid values are `host` and `task` | `string` | `null` | no |
| cpu | The number of cpu units used by the task. If the requires\_compatibilities is `FARGATE` this field is required. | `number` | `null` | no |
| memory | The amount (in MiB) of memory used by the task. If the requires\_compatibilities is `FARGATE` this field is required. | `number` | `null` | no |
| requires\_compatibilities | A list of launch types required by the task. The valid values are `EC2` and `FARGATE` | `list(string)` | `null` | no |
| iam\_role | ARN of the IAM role that allows Amazon ECS to make calls to your load balancer on your behalf. This parameter is required if you are using a load balancer with your service, but only if your task definition does not use the awsvpc network mode. If using awsvpc network mode, do not specify this role. If your account has already created the Amazon ECS service-linked role, that role is used by default for your service unless you specify a role here. | `string` | `null` | no |
| launch\_type | The launch type on which to run your service. The valid values are `EC2` and `FARGATE` | `string` | `EC2` | no |
| platform\_version | The platform version on which to run your service. Only applicable for launch_type set to `FARGATE` | `string` | `LATEST` | no |
| deployment\_maximum\_percent | The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment. Not valid when using the `DAEMON` scheduling strategy. | `number` | `null` | no |
| deployment\_minimum\_healthy\_percent | The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment. | `number` | `null` | no |
| desired\_count | The number of instances of the task definition to place and keep running. Defaults to 0. Do not specify if using the DAEMON scheduling strategy. | `number` | `null` | no |
| force\_new\_deployment | Enable to force a new task deployment of the service. This can be used to update tasks to use a newer Docker image with same image/tag combination (e.g. myimage:latest), roll Fargate tasks onto a newer platform version, or immediately deploy ordered\_placement\_strategy and placement\_constraints updates. | `bool` | `false` | no |
| health\_check\_grace\_period\_seconds | Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown, up to 2147483647. Only valid for services configured to use load balancers. | `number` | `null` | no |
| deployment\_controller | Type of deployment controller. Valid values are `CODE_DEPLOY` `ECS` `EXTERNAL` | `string` | `ECS` | no |
| scheduling_strategy | The scheduling strategy to use for the created service. The valid values are `REPLICA` and `DAEMON`. **Note that Tasks using the Fargate launch type or the CODE_DEPLOY or EXTERNAL deployment controller types don't support the DAEMON scheduling strategy.** | `string` | `REPLICA` | no |
| volumes | A list of volume blocks that containers in your task may use, defined below. | `list(object)` | `null` | no |
| inference\_accelerators | List of  Inference Accelerators settings, defined below. | `list(object)` | `null` | no |
| placement\_constraints | A list of placement constraints rules that are taken into consideration during task placement. Maximum number of placement\_constraints is 10. Defined below | `list(object)` | `null` | no |
| proxy\_configuration | The proxy configuration details for the App Mesh proxy, defined below. | `object` | `null` | no |
| capacity\_provider\_strategies | List of capacity provider strategies to use for the created service, defined below. | `list(object)` | `null` | no |
| load\_balancers | List of load balancers. defined below. | `list(object)` | `null` | no |
| network\_configuration | The network configuration for the service. This parameter is required for task definitions that use the awsvpc network mode to receive their own Elastic Network Interface, it is not supported for other network modes. | `object` | `null` | no |
| ordered\_placement\_strategy | Service level strategy rules that are taken into consideration during task placement. List from top to bottom in order of precedence. Updates to this configuration will take effect next task deployment unless `force_new_deployment` is enabled. The maximum number of ordered\_placement\_strategy objects is 5, defined below. | `list(object)` | `null` | no |
| service\_registries | The service discovery registries for the service, defined below | `object` | `null` | no |
| enable\_ecs\_managed\_tags | Specifies whether to enable Amazon ECS managed tags for the tasks within the service. | `bool` | `null` | no |
| propagate\_tags | Specifies whether to propagate the tags from the task definition or the service to the tasks. The valid values are `SERVICE` and `TASK_DEFINITION` | `string` | `null` | no |

> In order to use `enable_ecs_managed_tags` or `propagate_tags` you must first opt in to the new Amazon Resource Name (ARN) and resource identifier (ID) formats. For more information, see [Amazon Resource Names (ARNs) and IDs](https://docs.aws.amazon.com/AmazonECS/latest/userguide/ecs-account-settings.html#ecs-resource-ids).


### Objects in the **tasks(volumes)** list support the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the volume. This name is referenced in the sourceVolume parameter of the container definition in the mountPoints section. | `string` | `null` | yes |
| host\_path | The path on the host container instance that is presented to the container. If not set, ECS will create a nonpersistent data volume that starts empty and is deleted after the task has finished. | `string` | `null` | no |
| docker\_volume\_configuration |  Used to configure a docker volume, defined below. | `object` | `null` | no |
| efs\_volume\_configuration | Used to configure a EFS volume, defined below. | `object` | `null` | no |

### _Example:_
```
volumes = [
    {
        name      = "host_storage"
        host_path = "/ecs/service-storage"
    }]
```


### The **volumes(docker_volume_configuration)** object supports the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| scope | The scope for the Docker volume, which determines its lifecycle, can be either `task` or `shared` Docker volumes that are scoped to a task are automatically provisioned when the task starts and destroyed when the task stops. Docker volumes that are scoped as shared persist after the task stops. | `string` | `null` | no |
| autoprovision | If this value is `true` the Docker volume is created if it does not already exist. Note: This field is only used if the scope is `shared` | `bool` | `null` | no |
| driver | The Docker volume driver to use. The driver value must match the driver name provided by Docker because it is used for task placement. | `string` | `null` | no |
| driver_opts | A map of Docker driver specific options. | `map` | `null` | no |

### _Example:_
```
 volumes = [
    {
      name = "docker_vol"
      docker_volume_configuration = {
        scope         = "shared"
        autoprovision = true
        driver        = "local"

        driver_opts = {
          "type"   = "nfs"
          "device" = "${aws_efs_file_system.fs.dns_name}:/"
          "o"      = "addr=${aws_efs_file_system.fs.dns_name},rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport"
        }
      }
    }]
```


### The **volumes(efs_volume_configuration)** object supports the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| file\_system\_id | The ID of the EFS File System. | `string` | `null` | yes |
| root\_directory | The directory within the Amazon EFS file system to mount as the root directory inside the host. If this parameter is omitted, the root of the Amazon EFS volume will be used. Specifying / will have the same effect as omitting this parameter. This argument is ignored when using authorization\_config. | `string` | `null` | no |
| transit\_encryption | Whether or not to enable encryption for Amazon EFS data in transit between the Amazon ECS host and the Amazon EFS server. Transit encryption must be enabled if Amazon EFS IAM authorization is used. Valid values are `ENABLED` or `DISABLED` | `string` | `DISABLED` | no |
| transit\_encryption\_port | The port to use for transit encryption. If you do not specify a transit encryption port, it will use the port selection strategy that the Amazon EFS mount helper uses. | `number` | `null` | no |
| authorization\_config | The authorization configuration details for the Amazon EFS file system, defined below. | `string` | `null` | no |


### The **efs_volume_configuration(authorization_config)** object supports the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access_point_id | The access point ID to use. If an access point is specified, the root directory value will be relative to the directory set for the access point. If specified, transit encryption must be enabled in the EFSVolumeConfiguration. | `string` | `null` | no |
| iam | Whether or not to use the Amazon ECS task IAM role defined in a task definition when mounting the Amazon EFS file system. If enabled, transit encryption must be enabled in the EFSVolumeConfiguration. Valid values are `ENABLED` or `DISABLED` | `string` | `DISABLED` | no |

### _Example:_
```
volumes = [
    {
      name = "efs"
      efs_volume_configuration = {
        file_system_id          = aws_efs_file_system.fs.id
        root_directory          = "/opt/data"
        transit_encryption      = "ENABLED"
        transit_encryption_port = 2999
        authorization_config {
          access_point_id = aws_efs_access_point.test.id
          iam = "ENABLED"
        }
      }
    }]
```

A full example can be found [here](https://github.com/coresolutions-ltd/terraform-aws-ecs/tree/master/examples/volumes.tf).


### Objects in the **tasks(inference_accelerators)** list support the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| device\_name | The Elastic Inference accelerator device name. The deviceName must also be referenced in a container definition as a ResourceRequirement. | `string` | `null` | yes |
| device\_type | The Elastic Inference accelerator type to use. | `string` | `null` | yes |

### _Example:_
```
inference_accelerator {
  device_name = "device_1"
  device_type = "eia1.medium"
}
```


### Objects in the **tasks(placement_constraints)** list support the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| type | The type of constraint. Use memberOf to restrict selection to a group of valid candidates. Note that distinctInstance is not supported in task definitions. | `string` | `null` | yes |
| expression | Cluster Query Language expression to apply to the constraint. For more information, see Cluster Query Language in the Amazon EC2 Container Service Developer Guide. | `string` | `null` | no |

### _Example:_
```
placement_constraints {
  type       = "memberOf"
  expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
}
```


### The **tasks(proxy_configuration)** object supports the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| container\_name | The name of the container that will serve as the App Mesh proxy. | `string` | `null` | no |
| properties | The set of network configuration parameters to provide the Container Network Interface (CNI) plugin, specified a key-value mapping. | `string` | `null` | no |
| type | The proxy type. | `string` | `APPMESH` | no |

### _Example:_
```
proxy_configuration = {
  type           = "APPMESH"
  container_name = "applicationContainerName"
  properties = {
    AppPorts         = "8080"
    EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
    IgnoredUID       = "1337"
    ProxyEgressPort  = 15001
    ProxyIngressPort = 15000
  }
}
```


### Objects in the **tasks(capacity_provider_strategies)** list support the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| capacity\_provider | The short name of the capacity provider, can also be `FARGATE` or `FARGATE_SPOT` | `string` | `null` | yes |
| weight | The relative percentage of the total number of launched tasks that should use the specified capacity provider. | `number` | `null` | no |
| base | The number of tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined. | `number` | `null` | no |

### _Example:_
```
capacity_provider_strategies = [{
    capacity_provider = "FARGATE"
    weight            = 50
    base              = 1
  },
  {
    capacity_provider = "FARGATE_SPOT"
    weight            = 50
  }]
```
A full example can be found [here](https://github.com/coresolutions-ltd/terraform-aws-ecs/tree/master/examples/fargate_strategies.tf).


### Objects in the **tasks(load_balancers)** list support the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| elb\_name | The name of the ELB (Classic) to associate with the service (Required for ELB Classic) | `string` | `null` | no |
| target\_group\_arn | The ARN of the Load Balancer target group to associate with the service (Required for ALB/NLB) | `string` | `null` | no |
| container\_name | The name of the container to associate with the load balancer (as it appears in a container definition). | `string` | `null` | yes |
| container\_port | The port on the container to associate with the load balancer. | `number` | `null` | no |


### The **tasks(network_configuration)** object supports the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| subnets | The subnets associated with the task or service. | `list(string)` | `null` | no |
| security\_groups | The security groups associated with the task or service. If you do not specify a security group, the default security group for the VPC is used. | `list(string)` | `null` | no |
| assign\_public\_ip | Assign a public IP address to the ENI (Fargate launch type only). | `bool` | `false` | no |

### _Example:_
```
network_configuration = {
  subnets          = data.aws_subnet_ids.public.ids
  security_groups  = [aws_security_group.sg.id]
  assign_public_ip = true
}
```


### Objects in the **tasks(ordered_placement_strategy)** list support the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| type | The type of placement strategy. Must be one of `binpack` `random` or `spread` | `string` | `null` | yes |
| field | For the spread placement strategy, valid values are instanceId (or host, which has the same effect), or any platform or custom attribute that is applied to a container instance. For the binpack type, valid values are memory and cpu. For the random type, this attribute is not needed.  | `string` | `null` | no |


### The **tasks(service_registries)** object supports the following:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| registry\_arn | The ARN of the Service Registry. The currently supported service registry is Amazon Route 53 Auto Naming Service(aws\_service\_discovery\_service). | `string` | `null` | yes |
| port | The port value used if your Service Discovery service specified an SRV record. | `number` | `null` | no |
| container\_port | The port value, already specified in the task definition, to be used for your service discovery service. | `number` | `null` | no |
| container\_name | The container name value, already specified in the task definition, to be used for your service discovery service. | `string` | `null` | no |


## Outputs

| Name | Description |
|------|-------------|
| cluster\_arn | The Cluster ARN |
| cp\_arn | The capacity provider ARN |
| cp\_asg\_arn | The ARN for the capacity provider autoscaling Group |
| cp\_asg\_availability\_zones | The availability zones of the capacity provider autoscale group |
| cp\_asg\_name | The name of the capacity provider autoscale group |
| cp\_iam\_role\_arn | The capacity provider instance IAM role Amazon Resource Name (ARN) |
| cp\_iam\_role\_name | The capacity provider instance IAM role name |
| cp\_lt\_arn | The Amazon Resource Name (ARN) of the capacity provider launch template |
| cp\_lt\_id | The ID of the capacity provider launch template |
| service\_arns | The Amazon Resource Names (ARN) that identify the services |
| service\_names | The service names |
| task\_arns | The Amazon Resource Names (ARN) that identify the tasks |
| task\_families | The family of the Task Definitions |

---
## Notes

If using an ASG capacity provider the instances will require external network access to communicate with the Amazon ECS service. This can be acheieved by either setting `cp_associate_public_ip_address` to true to associate public ip addresses to the instances or by using either network address translation (NAT) or PrivateLink to establish the connection.
