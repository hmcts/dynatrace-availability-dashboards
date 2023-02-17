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

<!-- END_TF_DOCS -->

## Blackouts (Maintenance Windows)

There are two types of Maintenance Windows being handled by this repository:
  - Automated
    - Created [here](components/dt-availability-dashboards/auto_maintenance_window.tf) and used to turn off our HTTP monitors and alerting for the nonprod environments that are shut down during the evenings, and restarted in the morning. To change the settings for a specific environment, edit the {env}.tfvars file.
  - Manual
    - Created [here](components/dt-availability-dashboards/planned_maintenance_window.tf) and should be enabled in a case where we have a planned suspected outage for one or more environments, i.e a cluster switchover. To achieve this:
      - Set the enabled flag to true in a given {env}.tfvars file, for example in [demo](environments/demo/demo.tfvars#4)
      - Update the variables defined a given {env}.tfvars [file](environments/stg/stg.tfvars) file. This allows you to define the start, and end time of the planned outage within that environment.
