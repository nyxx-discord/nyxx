help:
	@fgrep -h "##" $(MAKEFILE_LIST) | sed -e 's/\(\:.*\#\#\)/\:\ /' | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

format: ## Run dart format
	dart format -l120 .

fix: ## Run dart fix
	dart fix --apply

analyze: ## Run dart analyze
	dart analyze

unit-tests: ## Run unit tests
	dart run test test/unit/**

integration-tests: ## Run integrations tests
	ifndef TEST_TOKEN $(error TEST_TOKEN is undefined) endif \
	ifndef TEST_TEXT_CHANNEL $(error TEST_TEXT_CHANNEL is undefined) endif \
	ifndef TEST_GUILD $(error TEST_GUILD is undefined) endif \
  	dart run test test/integration/**

fix-project: analyze fix format ## Fix whole project

test-project: unit-tests integration-tests ## Run all tests

check-project: fix-project test-project ## Run all checks