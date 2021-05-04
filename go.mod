module github.com/aws-quickstart/quickstart-helm-resource-provider

go 1.13

require (
	github.com/ahmetb/go-linq/v3 v3.2.0
	github.com/aws-cloudformation/cloudformation-cli-go-plugin v1.0.3
	github.com/aws/aws-lambda-go v1.23.0
	github.com/aws/aws-sdk-go v1.38.22
	github.com/docker/docker v17.12.0-ce-rc1.0.20200916142827-bd33bbf0497b+incompatible // indirect
	github.com/gofrs/flock v0.8.0
	github.com/gorilla/mux v1.8.0 // indirect
	github.com/opencontainers/runc v1.0.0-rc92 // indirect
	github.com/pkg/errors v0.9.1
	github.com/stretchr/testify v1.7.0
	helm.sh/helm/v3 v3.5.4
	k8s.io/api v0.20.4
	k8s.io/apiextensions-apiserver v0.20.4
	k8s.io/apimachinery v0.20.4
	k8s.io/cli-runtime v0.20.4
	k8s.io/client-go v0.20.4
	k8s.io/kubectl v0.20.4
	sigs.k8s.io/aws-iam-authenticator v0.5.2
	sigs.k8s.io/yaml v1.2.0
)

replace (
	github.com/docker/distribution => github.com/docker/distribution v0.0.0-20191216044856-a8371794149d
	github.com/docker/docker => github.com/moby/moby v17.12.0-ce-rc1.0.20200618181300-9dc6525e6118+incompatible
)
