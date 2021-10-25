.PHONY: generate-coverage
generate-coverage: coverage-tests integration-coverage coverage-format coverage-gen-html

.PHONY: integration-coverage
integration-coverage:
	(timeout 20s dart run test --coverage="coverage" --timeout=none test/integration/integration.dart; exit 0)

.PHONY: unit-coverage
coverage-tests:
	(timeout 10s dart run test --coverage="coverage" --timeout=none test/unit; exit 0)

.PHONY: coverage-format
coverage-format:
	dart run coverage:format_coverage --lcov --in=coverage --out=coverage/coverage.lcov --packages=.packages --report-on=lib

.PHONY: coverage-gen-html
coverage-gen-html:
	genhtml coverage/coverage.lcov -o coverage/coverage_gen
