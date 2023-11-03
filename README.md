# Kube Secret Inventory Tool
This tool will generate an inventory kubernetes secrets in excel format.

## Table of Context

- [Setup](#setup)
- [Usage](#usage)
- [Output](#output)
- [Contacts](#contacts)
  
## Setup

It's very easy to setup this tool. It's enough to run this:
```
sudo make setup
```

It will generate a new command called `ksi`.

## Usage

Once the ksi command will be generated, it's possible to run it.
This is the usage:

```
Usage: /usr/local/bin/ksi cluster-name
   - cluster-name: The name of the cluster.
   -h, --help: Display this help message.

IMPORTANT - remember to setup the $HOME/.kube in order to access to cluster with kubectl command.
```

## Output

This is an example of output:

```
> echo $PWD
/home
> ksi cluster-prod

------> Checking secrets in cluster cluster-prod....

---> Done processing secrets in namespace namespace1 on cluster cluster-prod
---> Done processing secrets in namespace namespace2 on cluster cluster-prod
---> Done processing secrets in namespace namespace3 on cluster cluster-prod
---> Done processing secrets in namespace namespace4 on cluster cluster-prod

------> Done processing secrets in all namespaces on cluster cluster-prod

Exporting secrets in excel file...
Done!
Created new excel file in /home/inventory/secret-inventory-cluster-prod.xlsx
```

The excel file contains follow columns:

- **Kube Secret**: name of kube secret
- **Type**: secret type
- **Age**: secret age (in days)
- **Namespace**: secret namespace
- **Created by**: secret owner
- **Service Account name**: secret service account
- **Expiration**: secret expiration (related to certs type)

## Contacts

In case of issue, reach out Gianluca Panzuto by [email](mailto:gianluca.panzuto@gmail.com)

