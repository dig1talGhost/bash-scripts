#!/usr/bin/env bash
set -e

###########################
##### mod-maintenance #####
###########################

# Script to do general maintenance on a go module.
# Make sure to run this script from project's root

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

logger_info() {
	echo -e "${BLUE}[INFO]${NC} $1" >&2
}

logger_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

logger_error() {
	echo -e "${RED}[ERR]${NC} $1" >&2
}

validate_license() {
	logger_info "Validating LICENSE..."

	if ! command -v "go-licenses" >/dev/null 2>&1; then
		go install github.com/google/go-licenses/v2@latest
	fi

	go-licenses check ./... \
		--disallowed_types=forbidden,restricted \
		--ignore=golang.org/x/sys && logger_success "Done."
	echo ""
}

if [[ ! -f "./go.mod" ]]; then
	logger_error ":: Not a Go module directory, exiting..."
	exit 1
fi

if ! command -v "go" >/dev/null 2>&1; then
	logger_error "command not found: go"
	exit 1
fi

if [[ -f "./LICENSE" ]]; then
	validate_license
fi

logger_info "Updating module dependencies..."

go get -u ./...
go mod tidy

logger_success "Done."
echo ""

logger_info "Running gofmt..."
gofmt -w -e .

logger_success "Done."
