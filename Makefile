.PHONY: help
help: ## display help
	@grep -F -h "##" $(MAKEFILE_LIST) | sed -e 's/\(\:.*\#\#\)/\:\ /' | grep -F -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: app-check
app-check: format-check generate-coverage  ## Run basic format checks and then generate code coverage

.PHONY: format-check
format-check: format analyze  ## Check basic format

.PHONY: generate-coverage
generate-coverage: integration-tests unit-tests coverage-format coverage-gen-html ## Run all test and generate html code coverage

.PHONY: generate-coverage-unit
generate-coverage-unit: unit-tests coverage-format coverage-gen-html ## Run unit tests ad generate coverage

.PHONY: integration-tests
integration-tests: ## Run integration tests with coverage
	(timeout 20s dart run test --coverage="coverage" --timeout=none test/integration/** ; exit 0)

.PHONY: unit-tests
unit-tests: ## Run unit tests with coverage
	(timeout 10s dart run test --coverage="coverage" --timeout=none test/unit/** ; exit 0)

.PHONY: coverage-format
coverage-format: ## Format dart coverage output to lcov
	dart run coverage:format_coverage --lcov --in=coverage --out=coverage/coverage.lcov --packages=.packages --report-on=lib

.PHONY: coverage-gen-html
coverage-gen-html: ## Generate html coverage from lcov data
	genhtml coverage/coverage.lcov -o coverage/coverage_gen

.PHONY: format
format: ## Run dart format
	dart format --set-exit-if-changed -l 160 ./lib

.PHONY: format-apply
format-apply: ## Run dart format
	dart format --fix -l 160 ./lib

.PHONY: format-apply-tests
format-apply-tests: ## Apply formatting to tests directory
	dart format --fix -l 160 ./test

.PHONY: analyze
analyze: ## Run dart analyze
	dart analyze
