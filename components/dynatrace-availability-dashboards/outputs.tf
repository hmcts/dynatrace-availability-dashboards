#output "management_zones" { value = local.management_zones }
#locals {
#  slos = dynatrace_slo.availability
#
#
#
#  final = { for slo in local.slos :
#    slo.id => slo
#  }
#}
#output "slos" { value = local.final }
