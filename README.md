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

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_containers"></a> [containers](#input\_containers) | Cloud Run containers | <pre>list(object({<br/>    name           = string<br/>    container_port = number<br/>    image          = string<br/>    depends_on     = list(string)<br/>    env            = map(string)<br/>    secret_env = optional(list(object({<br/>      name    = string<br/>      secret  = string<br/>      version = string<br/>    })), [])<br/>    volume_mounts = optional(object({<br/>      name       = string<br/>      mount_path = string<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_encryption_key"></a> [encryption\_key](#input\_encryption\_key) | KMS key resource name for CMEK encryption of container instances; if null uses Google-managed key | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | GCP project ID | `string` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | Cloud Run service configuration | <pre>object({<br/>    name         = string<br/>    location     = string<br/>    launch_stage = string<br/>    ingress      = string<br/>  })</pre> | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | Service account email to run the Cloud Run service as | `string` | n/a | yes |
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

resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "run.operations.get",
    "run.services.create",
    "run.services.delete",
    "run.services.get",
    "run.services.update"
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
