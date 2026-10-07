#!/usr/bin/env bash
set -e

########################
##### arch-mirrors #####
########################

# Automatically fetch and update archlinux mirrorlist.

# Usage:
#	   - Simply run the script and specify your country as first argument
#
# Example:
#	   - /path/to/script "MY_COUNTRY"
#
# Requires:
#	   - reflector
#	   - curl
#	   - git

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

COUNTRY="$1"
DETECT_OS=$([ -x "$(command -v pacman)" ] && pacman -Q base >/dev/null 2>&1 && echo "archlinux-$(uname -m)")

logger_info() {
	echo -e "${BLUE}[INFO]${NC} $1" >&2
}

logger_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

logger_error() {
	echo -e "${RED}[ERROR]${NC} $1" >&2
}

detect_system() {
	if [[ ! "${DETECT_OS}" =~ ^archlinux-x86_64$ ]]; then
		echo ""
		logger_error "This script only supports archlinux-x86_64 for now..."
		exit 1
	fi
}

detect_missing_packages() {
	local -a packages=(
		#	"curl"
		#	"git"
		"reflector"
	)
	for depends in "${packages[@]}"; do
		if ! command -v "${depends}" >/dev/null 2>&1; then
			echo ""
			logger_error "Missing dependency: ${depends}"
			logger_error "Run: sudo pacman -Syu ${depends}"
			exit 1
		fi
	done
}

print_usage() {
	echo ""
	logger_error "Country was not specified..."

	echo "Usage example:"
	echo "         /path/to/script.sh Germany"
}

main() {
	sudo -v
	clear

	echo -e "${BLUE}"
	cat <<"EOF"
########################
##### arch-mirrors #####
########################
EOF
	echo -e "${NC}"

	logger_info "This operation might take a while to complete..."
	logger_info "Fetching the latest mirrors available..."

	sudo reflector -c "${COUNTRY}" --protocol https \
		--latest 20 --age 6 --sort rate \
		--save /etc/pacman.d/mirrorlist

	sudo -v
	sudo chown -R root: /etc/pacman.d/mirrorlist
	sudo chmod 755 /etc/pacman.d/
	sudo chmod 644 /etc/pacman.d/mirrorlist

	sudo pacman -Syu
	echo ""

	logger_success "Finished updating the mirrorlist !"
}

detect_system
if [[ -z "${COUNTRY}" ]]; then
	print_usage && exit 1
fi

detect_missing_packages
main
