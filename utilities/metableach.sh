#!/usr/bin/env bash
set -e

#########################
##### metableach.sh #####
#########################

# Usage: ~/path/to/metableach.sh path/to/[TARGET_FILE]
# Requires: gum, exiftool

BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

function log_info() {
	echo -e "${BLUE}[INFO]${NC} $1" >&2
}

function log_error() {
	echo -e "${RED}[ERR]${NC} $1" >&2
}

TARGET_FILE="$1"

func_checkDepends() {
	local -a packages=(
		"gum"
		"exiftool"
	)
	for depend in "${packages[@]}"; do
		if ! command -v "$depend" >/dev/null 2>&1; then
			log_error "$depend is not installed, aborting..."
			exit 1
		fi
	done
}

func_Banner() {
	clear
	echo -e "${BLUE}"
	cat <<"EOF"
   __  ___    __       __   __             __
  /  |/  /__ / /____ _/ /  / /__ ___ _____/ /
 / /|_/ / -_) __/ _ `/ _ \/ / -_) _ `/ __/ _ \
/_/  /_/\__/\__/\_,_/_.__/_/\__/\_,_/\__/_//_/

EOF
	echo -e "A tool to remove the metadata off of any given file"
	echo -e "${RC}" && echo ""
}

main() {
	func_checkDepends && func_Banner

	if [[ -n "$TARGET_FILE" ]]; then
		exiftool "-gps*=" "-AllDates+=0:0:0 1:0:0" -All= "$TARGET_FILE"
	else
		log_error "TARGET_FILE not defined, no changes were made..."
		exit 1
	fi

	if gum confirm "Delete the original file?"; then
		rm -rf "$TARGET_FILE"_original
		log_info "Original file was deleted!"
		exit 0
	else
		exit 0
	fi
}
main
