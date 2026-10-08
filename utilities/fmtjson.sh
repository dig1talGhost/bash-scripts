#!/usr/bin/env bash
set -e

######################
##### fmtjson.sh #####
######################

# Format json using jq

# Run this script in the same directory as the target file
# Requires: jq
# Make sure to specify fileName as an argument (Must be json file)
# Example: ./fmtjson.sh "fileName.json"

BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

logger_info() {
	echo -e "${BLUE}[INFO]${NC} $1" >&2
}

logger_error() {
	echo -e "${RED}[ERR]${NC} $1" >&2
}

if ! command -v "jq" >/dev/null 2>&1; then
	logger_error "Dependency 'jq' not installed, aborting..."
	exit 1
else
	fileName="$1"
	jq '.' "$fileName" >/tmp/"$fileName" && mv /tmp/"$fileName" ./"$fileName" && logger_info "Done !"
fi
