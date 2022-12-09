#! /usr/bin/env bash
az account set --subscription $1
aks_resource_group=$2
aks_name=$3
environment=$4
department=$5

{
printf "\n\nTrying cluster $aks_name $aks_resource_group\n"
az aks get-credentials \
    --resource-group $aks_resource_group \
    --name $aks_name --admin
# Return false and fallback to cluster 01 if cluster returns 0 ingress objects
$(kubectl get ingress --context "$aks_name-admin" --all-namespaces=true -o \
    go-template='{{ $length := len .items }} {{ if eq $length 0 }}false{{ end }}')
} || {
aks_resource_group=$(echo $aks_resource_group|sed 's/-00-/-01-/g')
aks_name=$(echo $aks_name|sed 's/-00-/-01-/g')
printf "\n\nTrying cluster $aks_name $aks_resource_group\n"
az aks get-credentials \
    --resource-group $aks_resource_group \
    --name $aks_name --admin
}

printf "\nInstall python requirements\n\n"
cat scripts/requirements.txt
printf "\n\n"
python3 -m pip install --quiet -r scripts/requirements.txt
printf "\n\n"

python3 scripts/generate_synthetic_monitors.py \
    --environment $environment \
    --department $department \
    --context $aks_name-admin
