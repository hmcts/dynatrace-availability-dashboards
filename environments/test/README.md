Terraform cnp template works only with "test" environment keys instead of "perftest".
While both environment directory and tfvars file is set to "test" the actuall
environment key within tfvars is still set to "perftest".
