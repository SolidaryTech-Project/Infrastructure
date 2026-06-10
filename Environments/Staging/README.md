# Staging

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.28.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.17 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.14 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 3.0.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_databases"></a> [databases](#module\_databases) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/databases | main |
| <a name="module_donation_queue"></a> [donation\_queue](#module\_donation\_queue) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/queue | main |
| <a name="module_ecr_donation"></a> [ecr\_donation](#module\_ecr\_donation) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/ecr | main |
| <a name="module_ecr_ngo"></a> [ecr\_ngo](#module\_ecr\_ngo) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/ecr | main |
| <a name="module_ecr_volunteer"></a> [ecr\_volunteer](#module\_ecr\_volunteer) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/ecr | main |
| <a name="module_eks"></a> [eks](#module\_eks) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/eks-cluster | main |
| <a name="module_eks_nodegroup"></a> [eks\_nodegroup](#module\_eks\_nodegroup) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/eks-nodegroup | main |
| <a name="module_helm"></a> [helm](#module\_helm) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/helm | main |
| <a name="module_kubernetes"></a> [kubernetes](#module\_kubernetes) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/kubernetes | main |
| <a name="module_network"></a> [network](#module\_network) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/Network | main |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/secrets_manager | main |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy resources | `string` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Default database name created inside the RDS instance | `string` | `"solidarytech"` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | Desired number of worker nodes | `number` | `2` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g. development, staging, production) | `string` | n/a | yes |
| <a name="input_instance_types"></a> [instance\_types](#input\_instance\_types) | EC2 instance types for the EKS node group | `list(string)` | <pre>[<br>  "t3.medium"<br>]</pre> | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of worker nodes | `number` | `4` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of worker nodes | `number` | `2` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used as base for resource naming | `string` | n/a | yes |
| <a name="input_rds_username"></a> [rds\_username](#input\_rds\_username) | Master username for the RDS instance | `string` | `"solidarytech"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
