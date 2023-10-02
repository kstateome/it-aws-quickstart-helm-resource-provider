.PHONY: build package

TYPE_NAME ?= AWSQS::Kubernetes::Helm
TYPE_NAME_LOWER ?= awsqs-kubernetes-helm
REGION ?= us-east-1
BUCKET ?= quickstart-resource-dev
EX_ROLE ?= use-existing
LOG_ROLE ?= use-existing

build:
	go mod tidy -v
	cfn generate
	env CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -ldflags="-s -w" -tags="logging,lambda.norpc" -o bin/bootstrap2 cmd/main.go
	env CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -ldflags="-s -w" -tags="lambda.norpc" -o bin/bootstrap vpc/main.go

package: build
	cd bin ; zip -FS -X k8svpc.zip bootstrap ; rm bootstrap ; mv bootstrap2 bootstrap; zip -X ../handler.zip ./k8svpc.zip ./bootstrap ; cd ..
	cp  $(TYPE_NAME_LOWER).json schema.json
	zip -Xr $(TYPE_NAME_LOWER).zip ./handler.zip ./schema.json ./.rpdk-config ./inputs
	rm ./handler.zip ./schema.json

register:
	set -ex ; \
	R_LOG_ROLE=$(LOG_ROLE) ;\
	if [ "$(LOG_ROLE)" == "use-existing" ] ; then \
	  R_LOG_ROLE=`aws cloudformation describe-type --type RESOURCE --type-name "$(TYPE_NAME)" --region $(REGION) --output text --query LoggingConfig.LogRoleArn` ;\
    fi ;\
    R_EX_ROLE=$(EX_ROLE) ;\
    if [ "$(EX_ROLE)" == "use-existing" ] ; then \
	  R_EX_ROLE=`aws cloudformation describe-type --type RESOURCE --type-name "$(TYPE_NAME)" --region $(REGION) --output text --query ExecutionRoleArn` ;\
	fi ;\
	TOKEN=`aws cloudformation register-type \
		--type "RESOURCE" \
		--type-name  "$(TYPE_NAME)" \
		--schema-handler-package s3://$(BUCKET)/$(TYPE_NAME_LOWER).zip \
		--logging-config LogRoleArn=$${R_LOG_ROLE},LogGroupName=/cloudformation/registry/$(TYPE_NAME_LOWER) \
		--execution-role-arn $${R_EX_ROLE} \
		--region $(REGION) \
		--query RegistrationToken \
		--output text` ;\
	  while true; do \
		STATUS=`aws cloudformation describe-type-registration \
		  --registration-token $${TOKEN} \
		  --region $(REGION) --query ProgressStatus --output text` ;\
		if [ "$${STATUS}" == "FAILED" ] ; then \
		  aws cloudformation describe-type-registration \
		  --registration-token $${TOKEN} \
		  --region $(REGION) ;\
		  exit 1 ; \
		fi ; \
		if [ "$${STATUS}" == "COMPLETE" ] ; then \
		  ARN=`aws cloudformation describe-type-registration \
		  --registration-token $${TOKEN} \
		  --region $(REGION) --query TypeVersionArn --output text` ;\
		  break ; \
		fi ; \
		sleep 5 ; \
	  done ;\
	  aws cloudformation set-type-default-version --arn $${ARN} --region $(REGION)
