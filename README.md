# AWSQS::Kubernetes::Helm

An AWS CloudFormation resource provider for the management of helm 3 resources in EKS and self-managed Kubernetes clusters.

## Prerequisites

### IAM role
An IAM role is used by CloudFormation to execute the Helm resource type handler code. 
A CloudFormation template to create the exeecution role is available 
[here](https://github.com/aws-quickstart/quickstart-helm-resource-provider/blob/main/execution-role.template.yaml)

### Create an EKS cluster and provide CloudFormation access to the Kubernetes API
EKS clusters use IAM to allow access to the kubernetes API, as the CloudFormation resource types in this project 
interact with the kubernetes API, the IAM execution role must be granted access to the kubernetes API. This can be done 
in one of two ways:
* Create the cluster using CloudFormation: Currently there is no native way to manage EKS auth using CloudFormation 
  (+1 [this GitHub issue](https://github.com/aws/containers-roadmap/issues/554) to help prioritize native support). 
  For this reason we have published `AWSQS::EKS::Cluster`. Instructions on activation and usage can be found 
  [here](https://github.com/aws-quickstart/quickstart-amazon-eks-cluster-resource-provider/blob/main/README.md).
* Manually: to allow this resource type to access the kubernetes API, follow the 
  [instructions in the EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html) adding 
  the IAM execution role created above to the `system:masters` group. (Note: you can scope this down if you plan to use 
  the resource type to only perform specific operations on the kubernetes cluster)

## Registering the Resource type
To privately register the helm resource type into your account a CloudFromation template has been 
provided [here](https://github.com/aws-quickstart/quickstart-helm-resource-provider/blob/main/register-type.template.yaml). 
Note that this must be run in each region yo plan to use this project in.

## Usage
Properties and return values are documented [here](./docs/README.md).

## Examples

### Install kube-state-metrics chart into the cluster
```yaml
AWSTemplateFormatVersion: "2010-09-09"
Resources:
  KubeStateMetrics:
    Type: "AWSQS::Kubernetes::Helm"
    Properties:
      ClusterID: my-cluster-name
      Name: kube-state-metrics
      Namespace: kube-state-metrics
      Repository: https://prometheus-community.github.io/helm-charts
      Chart: prometheus-community/kube-state-metrics
```

### Install kube-state-metrics chart enabling monitoring using helm values
```yaml
AWSTemplateFormatVersion: "2010-09-09"
Resources:
  KubeStateMetrics:
    Type: "AWSQS::Kubernetes::Helm"
    Properties:
      ClusterID: my-cluster-name
      Name: kube-state-metrics
      Namespace: kube-state-metrics
      Repository: https://prometheus-community.github.io/helm-charts
      Chart: prometheus-community/kube-state-metrics
      Values: |
        prometheus:
          monitor:
            enabled: true
```
