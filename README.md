# terraform-gcp-cloudrun

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-cloudrun/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-cloudrun)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-cloudrun.svg)](https://github.com/JamesWoolfenden/terraform-gcp-cloudrun/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-cloudrun.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-cloudrun/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.14.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![checkov](https://img.shields.io/badge/checkov-verified-brightgreen)](https://www.checkov.io/)

## Usage

Add **module.cloudrun.tf** to your code:-

```terraform
module "cloudrun" {
  source             = "JamesWoolfenden/cloudrun/gcp"
  version            = "0.0.1"
}
```

## Auth

```bash
gcloud auth application-default login --project yourproj
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_cloud_run_v2_service.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |
| [google_kms_crypto_key_iam_member.cloud_run_service_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_monitoring_uptime_check_config.private](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_uptime_check_config) | resource |
| [google_monitoring_uptime_check_config.public](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_uptime_check_config) | resource |
| [google_service_directory_endpoint.uptime](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_directory_endpoint) | resource |
| [google_service_directory_namespace.uptime](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_directory_namespace) | resource |
| [google_service_directory_service.uptime](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_directory_service) | resource |
| [google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_containers"></a> [containers](#input\_containers) | Cloud Run containers | <pre>list(object({<br/>    name           = string<br/>    container_port = number<br/>    image          = string<br/>    depends_on     = list(string)<br/>    env            = map(string)<br/>    secret_env = optional(list(object({<br/>      name    = string<br/>      secret  = string<br/>      version = string<br/>    })), [])<br/>    volume_mounts = optional(object({<br/>      name       = string<br/>      mount_path = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_encryption_key"></a> [encryption\_key](#input\_encryption\_key) | KMS key resource name for CMEK encryption of container instances; if null uses Google-managed key | `string` | n/a | yes |
| <a name="input_liveness_probe"></a> [liveness\_probe](#input\_liveness\_probe) | Liveness probe applied to the primary (first) container; null means no liveness probe is configured (Cloud Run relies on the container staying up, with no active restart-on-hang check). | <pre>object({<br/>    initial_delay_seconds = optional(number)<br/>    timeout_seconds       = optional(number)<br/>    period_seconds        = optional(number)<br/>    failure_threshold     = optional(number)<br/>    http_get = optional(object({<br/>      path = optional(string)<br/>      port = optional(number)<br/>      http_headers = optional(list(object({<br/>        name  = string<br/>        value = optional(string)<br/>      })), [])<br/>    }))<br/>    grpc = optional(object({<br/>      port    = optional(number)<br/>      service = optional(string)<br/>    }))<br/>    tcp_socket = optional(object({<br/>      port = optional(number)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_max_instance_count"></a> [max\_instance\_count](#input\_max\_instance\_count) | Maximum number of container instances Cloud Run may scale to; null uses the project default (no per-service ceiling) | `number` | `null` | no |
| <a name="input_min_instance_count"></a> [min\_instance\_count](#input\_min\_instance\_count) | Minimum number of container instances to keep warm; null allows scale-to-zero (default Cloud Run behavior) | `number` | `null` | no |
| <a name="input_private_check_endpoint"></a> [private\_check\_endpoint](#input\_private\_check\_endpoint) | Optional private target for a VPC-based (VPC\_CHECKERS) uptime check,<br/>used only when service.ingress is not INGRESS\_TRAFFIC\_ALL. Point it at<br/>the internal IP:port of whatever fronts this service on the private<br/>network - an internal Application Load Balancer forwarding rule (for<br/>INGRESS\_TRAFFIC\_INTERNAL\_LOAD\_BALANCER) or a Private Service Connect<br/>endpoint (for INGRESS\_TRAFFIC\_INTERNAL\_ONLY). This module registers that<br/>endpoint in Service Directory and points the uptime check at it; it does<br/>not create the load balancer/PSC endpoint itself, since it doesn't own<br/>that network topology.<br/><br/>`network` is the target VPC's self-link in the form<br/>projects/PROJECT\_NUMBER/locations/global/networks/NETWORK\_NAME.<br/>`service_directory_location` is the region for the Service Directory<br/>namespace, e.g. "us-central1" - typically the same region as the service.<br/><br/>The caller must separately allow inbound TCP from 35.199.192.0/19 on<br/>that network, and grant the Cloud Monitoring service agent<br/>roles/servicedirectory.viewer and roles/servicedirectory.pscAuthorizedService<br/>- this module does not manage that network's firewall rules or IAM.<br/><br/>If left null while ingress is restricted, no uptime check is created at<br/>all - there's nothing reachable to monitor without an endpoint. | <pre>object({<br/>    ip                         = string<br/>    port                       = number<br/>    network                    = string<br/>    service_directory_location = string<br/>  })</pre> | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | GCP project ID | `string` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | Cloud Run service configuration | <pre>object({<br/>    name         = string<br/>    location     = string<br/>    launch_stage = string<br/>    ingress      = string<br/>  })</pre> | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Service account email to run the Cloud Run service as | `string` | n/a | yes |
| <a name="input_startup_probe"></a> [startup\_probe](#input\_startup\_probe) | Startup probe applied to the primary (first) container; null uses Cloud Run's default TCP-open probe. Set exactly one of http\_get, tcp\_socket, or grpc. | <pre>object({<br/>    initial_delay_seconds = optional(number)<br/>    timeout_seconds       = optional(number)<br/>    period_seconds        = optional(number)<br/>    failure_threshold     = optional(number)<br/>    http_get = optional(object({<br/>      path = optional(string)<br/>      port = optional(number)<br/>      http_headers = optional(list(object({<br/>        name  = string<br/>        value = optional(string)<br/>      })), [])<br/>    }))<br/>    tcp_socket = optional(object({<br/>      port = optional(number)<br/>    }))<br/>    grpc = optional(object({<br/>      port    = optional(number)<br/>      service = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Template-level volumes; each name must be referenced by a container volume\_mounts entry | <pre>list(object({<br/>    name = string<br/>    empty_dir = optional(object({<br/>      medium     = optional(string, "MEMORY")<br/>      size_limit = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_vpc_connector"></a> [vpc\_connector](#input\_vpc\_connector) | VPC connector ID for Cloud Run VPC egress; if null the vpc\_access block is omitted | `string` | n/a | yes |
| <a name="input_vpc_egress"></a> [vpc\_egress](#input\_vpc\_egress) | VPC Access Connector egress setting; PRIVATE\_RANGES\_ONLY routes only RFC-1918 traffic through the connector, ALL\_TRAFFIC forces all egress through VPC (requires Cloud NAT for internet access) | `string` | `"PRIVATE_RANGES_ONLY"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_service"></a> [service](#output\_service) | The Cloud Run service resource |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Information

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",
    "monitoring.uptimeCheckConfigs.create",
    "monitoring.uptimeCheckConfigs.delete",
    "monitoring.uptimeCheckConfigs.get",
    "monitoring.uptimeCheckConfigs.update",
    "resourcemanager.projects.get",
    "run.operations.get",
    "run.services.create",
    "run.services.delete",
    "run.services.get",
    "run.services.update",
    "servicedirectory.endpoints.create",
    "servicedirectory.endpoints.delete",
    "servicedirectory.endpoints.get",
    "servicedirectory.endpoints.update",
    "servicedirectory.services.create",
    "servicedirectory.services.delete",
    "servicedirectory.services.get",
    "servicedirectory.services.update"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "monitoring.uptimeCheckConfigs.get",
    "resourcemanager.organizations.get",
    "resourcemanager.projects.get",
    "run.operations.get",
    "run.services.get",
    "servicedirectory.endpoints.get",
    "servicedirectory.services.get"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Related Projects

Check out these related projects.

- [terraform-aws-codecommit](https://github.com/jameswoolfenden/terraform-aws-codebuild) - Storing ones code

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-aws-bigquery/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-aws-bigquery/issues) to report any bugs or file feature requests.

## Copyrights

Copyright � 2023-2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
