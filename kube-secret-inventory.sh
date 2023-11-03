#!/bin/bash

# This script is created by Gianluca Panzuto
# Copyright (C) Nov 3rd, 2023 Gianluca Panzuto
# All rights reserved.

function usage() {
    echo "Usage: $0 cluster-name"
    echo "   - cluster-name: The name of the cluster."
    echo "   -h, --help: Display this help message."
    echo ""
    echo "IMPORTANT - remember to setup the $HOME/.kube in order to access to cluster with kubectl command."

}

# Function to process secrets in a namespace

process_secrets() {

    namespace="$1"
    cluster="$2"

    kube_secrets=$(kubectl get secrets -n "$namespace" | awk '{print $1}' | tail -n +2)

    for kube_secret in $kube_secrets; do
        
        # get the secret type

        json_secret=$(kubectl get secret $kube_secret -n $namespace -o json)

        type=$(echo $json_secret | jq -r '.type')

        # get the "potential" expiration

        if [[ $type == "kubernetes.io/tls" ]]; then
            expiration=$(echo $json_secret | jq -r '.data."tls.crt"' | base64 -d | openssl x509 -enddate -noout | sed 's/ /-/g')
        elif [[ $type == "kubernetes.io/service-account-token" ]]; then
            expiration=$(echo $json_secret | jq -r  '.data."ca.crt"' | base64 -d | openssl x509 -enddate -noout | sed 's/ /-/g')
        else
            expiration="None"
        fi
        
        # secret age calculation (in days)

        timestamp=$(echo $json_secret | jq -r '.metadata.creationTimestamp')
        timestamp_seconds=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp" "+%s")
        current_seconds=$(date "+%s")
        difference_seconds=$((timestamp_seconds - current_seconds))
        abs_difference_seconds=${difference_seconds#-}
        difference_days=$((abs_difference_seconds / 86400))
        difference_days=${difference_days}d

        # get the "created-by" and "service-account.name" secret infos
        
        created_by=$(echo $json_secret | jq -r '.metadata.annotations."kubernetes.io/created-by"')

        if [[ $created_by == "null" ]]; then
            created_by="None"
        fi

        service_account_name=$(echo $json_secret | jq -r '.metadata.annotations."kubernetes.io/service-account.name"')

        if [[ $service_account_name == "null" ]]; then
            service_account_name="None"
        fi

        # Store all secrets in a txt file that will be converted in excel

        echo "$kube_secret $type $difference_days $namespace $created_by $service_account_name $expiration" >> inventory/secret-inventory-$cluster.txt
    done
    echo "---> Done processing secrets in namespace $namespace on cluster $cluster"
}

# Check if the script is called with the help option

if [ "$#" -eq 1 ] && ( [ "$1" == "-h" ] || [ "$1" == "--help" ] ); then
    usage
    exit 0
fi

# Check if the script is called with exactly one parameter

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters!"
    usage
    exit 1
fi

cluster=$1

# Each inventory will be stored in a folder called "inventory"

rm -rf inventory
mkdir -p inventory

# Export the function and cluster variable, so xargs can use them

export -f process_secrets
export cluster

# Loop through clusters and namespaces and use xargs for parallel processing

namespaces=$(kubectl get ns | awk '{print $1}' | tail -n +2)

echo ""
echo "------> Checking secrets in cluster $cluster...."
echo ""

# Use xargs to process namespaces in parallel

echo "$namespaces" | xargs -I {} -P 8 bash -c 'process_secrets "{}" "$cluster"'
echo ""
echo "------> Done processing secrets in all namespaces on cluster $cluster"

# Convert the txt file to excel, called secret-inventory-<cluster-name>.xlsx and stored under "inventory" folder

echo ""
echo "Exporting secrets in excel file..."
python3 converter.py --input inventory/secret-inventory-$cluster.txt --output inventory/secret-inventory-$cluster.xlsx
echo "Done!"
echo "Created new excel file in $PWD/inventory/secret-inventory-$cluster.xlsx"
echo ""
rm inventory/secret-inventory-$cluster.txt

