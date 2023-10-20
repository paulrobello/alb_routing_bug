.PHONY: make-tf-vars all clean deploy build-zips stack-init dump-outputs destroy exec-api-all exec-api-route-1 exec-api-route-2 exec-api-route-not-found

export AWS_REGION = us-east-1

# directory structure
IAC_DIR := ./iac
SRC_DIR := ./src

# commands for ls override
TF_CMD = tflocal
AWS_CMD = awslocal

# these change after ls restart need to fetch on each ref
VPC_ID = $(shell $(AWS_CMD) ec2 describe-vpcs --region $(AWS_REGION) --query 'Vpcs[0].VpcId' | jq -cr)
VPC_SUBNET_IDS = $(shell $(AWS_CMD) ec2 describe-subnets --region $(AWS_REGION) --query 'Subnets[].SubnetId' | jq -cr)
VPC_SG_IDS = $(shell $(AWS_CMD) ec2 describe-security-groups --region $(AWS_REGION) --query 'SecurityGroups[].GroupId' | jq -cr)



all: clean stack-init build deploy

# output set of vars that all tf commands should use
make-tf-vars:
	rm $(IAC_DIR)/*.auto.tfvars -f
	echo 'lambda_subnet_ids=$(VPC_SUBNET_IDS)' > $(IAC_DIR)/$(STACK_SUFFIX).auto.tfvars
	echo 'lambda_security_group_ids=$(VPC_SG_IDS)' >> $(IAC_DIR)/$(STACK_SUFFIX).auto.tfvars
	echo 'vpc_id="$(VPC_ID)"' >> $(IAC_DIR)/$(STACK_SUFFIX).auto.tfvars

clean: delete-zips
	rm -f outputs.*.json
	cd $(IAC_DIR) && rm -rf terraform.* terraform.tfstate* .terraform* *.auto.tfvars

stack-init: make-tf-vars
	cd $(IAC_DIR) && $(TF_CMD) init -upgrade -reconfigure -lock=false

deploy: build stack-init make-tf-vars
	cd $(IAC_DIR) && $(TF_CMD) apply -auto-approve -lock=false \
	&& $(TF_CMD) output -json > ../outputs.json

destroy:
	stop-ls.sh
	start-ls.sh

# source packaging and assembly ---------------------------------------

PKG_SUBDIRS := $(dir $(shell find src -name "makefile"))

build: $(PKG_SUBDIRS)
	for i in $(PKG_SUBDIRS); do \
        $(MAKE) -C $$i build; \
    done

delete-zips:
	find ./src -type f -name '*.zip' -delete


it-again: destroy clean all

#--------- [ API ] ------------
exec-api-all: exec-api-route-1 exec-api-route-2 exec-api-route-not-found

exec-api-route-1:
	@API_KEY=$$(jq -r '.api_key_value.value' outputs.json); \
	INVOKE_URL=$$(jq -r '.alb_invoke_url.value' outputs.json); \
	RES=$$(curl -sk -X GET \
	-H "Content-Type: application/json" \
	-H "X-API-KEY: $$API_KEY" \
	-k "$$INVOKE_URL/route1" | jq -c '.message'); \
	echo "Expected: \"Route1\"          Got: $$RES"

exec-api-route-2:
	@API_KEY=$$(jq -r '.api_key_value.value' outputs.json); \
	INVOKE_URL=$$(jq -r '.alb_invoke_url.value' outputs.json); \
	RES=$$(curl -sk -X GET \
	-H "Content-Type: application/json" \
	-H "X-API-KEY: $$API_KEY" \
	-k "$$INVOKE_URL/route2" | jq -c '.message'); \
	echo "Expected: \"Route2\"          Got: $$RES"

exec-api-route-not-found:
	@API_KEY=$$(jq -r '.api_key_value.value' outputs.json); \
	INVOKE_URL=$$(jq -r '.alb_invoke_url.value' outputs.json); \
	RES=$$(curl -sk -X GET \
	-H "Content-Type: application/json" \
	-H "X-API-KEY: $$API_KEY" \
	-k "$$INVOKE_URL/not-found" | jq -c '.message'); \
	echo "Expected: \"404 not found\"   Got: $$RES"
