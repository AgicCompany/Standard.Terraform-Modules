.PHONY: validate validate-all lint lint-all fmt fmt-all docs

# ─── Single module targets (require MODULE=<name>) ───────────────────────────

validate:
ifndef MODULE
	$(error MODULE is required. Usage: make validate MODULE=storage-account)
endif
	@echo "=== Validating modules/$(MODULE) ==="
	terraform fmt -check -recursive "modules/$(MODULE)"
	terraform -chdir="modules/$(MODULE)" init -backend=false -input=false -no-color
	terraform -chdir="modules/$(MODULE)" validate
	@for example in modules/$(MODULE)/examples/*/; do \
		[ -d "$$example" ] || continue; \
		echo "--- Validating $$(basename $$example) example ---"; \
		terraform -chdir="$$example" init -backend=false -input=false -no-color; \
		terraform -chdir="$$example" validate; \
	done
	@echo "=== $(MODULE) OK ==="

lint:
ifndef MODULE
	$(error MODULE is required. Usage: make lint MODULE=storage-account)
endif
	@command -v tflint >/dev/null 2>&1 || { echo "Error: tflint is not installed. Install from https://github.com/terraform-linters/tflint"; exit 1; }
	tflint --init
	tflint --chdir="modules/$(MODULE)"

fmt:
ifndef MODULE
	$(error MODULE is required. Usage: make fmt MODULE=storage-account)
endif
	terraform fmt -recursive "modules/$(MODULE)"

# ─── All-module targets ──────────────────────────────────────────────────────

validate-all:
	@failed=""; \
	for dir in modules/*/; do \
		module=$$(basename "$$dir"); \
		echo "=== Validating $$module ==="; \
		$(MAKE) validate MODULE="$$module" || failed="$$failed $$module"; \
	done; \
	if [ -n "$$failed" ]; then \
		echo "FAILED modules:$$failed"; \
		exit 1; \
	fi; \
	echo "All modules passed validation."

lint-all:
	@command -v tflint >/dev/null 2>&1 || { echo "Error: tflint is not installed. Install from https://github.com/terraform-linters/tflint"; exit 1; }
	@failed=""; \
	for dir in modules/*/; do \
		module=$$(basename "$$dir"); \
		echo "=== Linting $$module ==="; \
		$(MAKE) lint MODULE="$$module" || failed="$$failed $$module"; \
	done; \
	if [ -n "$$failed" ]; then \
		echo "FAILED modules:$$failed"; \
		exit 1; \
	fi; \
	echo "All modules passed linting."

fmt-all:
	@for dir in modules/*/; do \
		module=$$(basename "$$dir"); \
		echo "=== Formatting $$module ==="; \
		terraform fmt -recursive "$$dir"; \
	done; \
	echo "All modules formatted."

# ─── Docs ────────────────────────────────────────────────────────────────────

docs:
	./scripts/generate-docs.sh
