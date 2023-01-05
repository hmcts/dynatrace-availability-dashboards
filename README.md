# Dynatrace Availability Dashboards


## Purpose

The purpose of this repository is to automate the creation of Synthetic Monitors, Management Zones, SLOS and Dashboards within Dynatrace, by querying Ingress objects in each environment on the CFT Kubernetes clusters

## What's inside?

* **Terraform**<br>
  [Components](components/dt-availability-dashboards) defined in Terraform to build associated infrastructure
* **Python and Bash [scripts](scripts)</br>**
  These scripts are used to:
    * Autogenerate yaml files per-environment based on Ingress objects withiin clusters, to update Terraform configuration files
    * Create Pull Requests if there are changes to Ingress objects within clusters
* **Azure pipelines**
    * [Daily](azure-pipelines-daily.yaml) - Runs each morning at 7AM to fetch latest changes
    * [Deployment](azure-pipelines.yaml) - Deploy infrastructure changes and update dahsboards
* **Github Actions**<br>
  We use Github Actions to run:
    * [Pre-Commit](.github/workflows/pre-commit.yaml) checks
    * [Unit Tests](.github/workflows/unit-tests.yaml)
* **Renovate**<br>
  [Renovate](.github/renovate.json) is configured to keep our dependencies up-to-date and keep a running dashboard

### Terraform docs
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.3.7 |
| <a name="requirement_dynatrace"></a> [dynatrace](#requirement\_dynatrace) | 1.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_dynatrace"></a> [dynatrace](#provider\_dynatrace) | 1.16.0 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Resources

| Name | Type |
|------|------|
| [dynatrace_dashboard.availability](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/1.16.0/docs/resources/dashboard) | resource |
| [dynatrace_http_monitor.availability](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/1.16.0/docs/resources/http_monitor) | resource |
| [dynatrace_management_zone.availability](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/1.16.0/docs/resources/management_zone) | resource |
| [dynatrace_slo.availability](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/1.16.0/docs/resources/slo) | resource |
| [time_sleep.management_zones](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_builtFrom"></a> [builtFrom](#input\_builtFrom) | builtFrom variable required by cnp terraform template. Not in use by terraform | `string` | `null` | no |
| <a name="input_dt_env_url"></a> [dt\_env\_url](#input\_dt\_env\_url) | Dynatrace environment URL | `string` | n/a | yes |
| <a name="input_dynatrace_platops_api_key"></a> [dynatrace\_platops\_api\_key](#input\_dynatrace\_platops\_api\_key) | Dynatrace API access key | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | Name of the environment to build in | `string` | n/a | yes |
| <a name="input_product"></a> [product](#input\_product) | product variable required by cnp terraform template. Not in use by terraform | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ado_dashboard_url"></a> [ado\_dashboard\_url](#output\_ado\_dashboard\_url) | Used to display created dashboard URLs as vso[task.logissue type=warning] |
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | Dynatrace Dashboard URL |
<!-- END_TF_DOCS -->
