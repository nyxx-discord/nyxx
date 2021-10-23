.PHONY: generate-coverage
generate-coverage: coverage-tests coverage-format coverage-gen-html

.PHONY: test-coverage
coverage-tests:
	dart run test --coverage="coverage" test/unit/**

.PHONY: coverage-format
coverage-format:
	dart run coverage:format_coverage --lcov --in=coverage --out=coverage/coverage.lcov --packages=.packages --report-on=lib

.PHONY: coverage-gen-html
coverage-gen-html:
	genhtml coverage/coverage.lcov -o coverage/coverage_gen
