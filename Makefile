.PHONY: build test clean lint

build:
	moon build

test:
	moon test

clean:
	rm -rf target/

lint:
	moon check

ci: lint test build
	@echo "All checks passed!"
