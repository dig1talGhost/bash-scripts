#!/usr/bin/env bash
set -e

######################
##### jsonify.sh #####
######################

# Usage: $0 KEY_NAME SRC_FILE TARGET_JSON
# Example: ./jsonify.sh "mylist" "list.txt" "list.json"

CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
RC='\033[0m'

KEY_NAME="$1"
SRC_FILE="$2"
TARGET_JSON="$3"

usage() {
	echo -e "${YELLOW}"
	cat <<EOF
Usage: $0 KEY_NAME SRC_FILE TARGET_JSON
Example: ./jsonify.sh "mylist" "list.txt" "list.json"
EOF
	echo -e "${RC}"
	exit 1
}

if [ "$#" -ne 3 ]; then
	usage
fi

check_depends() {
	local deps=(jq)
	for dep in "${deps[@]}"; do
		if ! command -v "$dep" >/dev/null 2>&1; then
			echo -e "${RED}:: Missing dependency: $dep. Aborting.${RC}"
			exit 1
		fi
	done
}

_confirm() {
	if command -v gum >/dev/null 2>&1; then
		gum confirm "$@"
		return $?
	else
		local prompt="${1:-Confirm?}"
		while true; do
			read -r -p "$prompt [y/N]: " yn
			case "$yn" in
			[Yy]*) return 0 ;;
			[Nn]* | "") return 1 ;;
			*) echo "Please answer y or n." ;;
			esac
		done
	fi
}

rm_src_confirm() {
	if _confirm ":: Delete $SRC_FILE?"; then
		rm -f -- "$SRC_FILE"
		echo -e "${CYAN}:: Deleted $SRC_FILE${RC}"
	else
		echo -e "${YELLOW}:: Left $SRC_FILE${RC}"
	fi
}

main() {
	if [ ! -f "$SRC_FILE" ]; then
		echo -e "${RED}:: $SRC_FILE: no such file or directory. Aborting.${RC}"
		exit 1
	fi

	local tmp
	tmp="$(mktemp --tmpdir jsonify.XXXXXX)" || {
		echo -e "${RED}:: Failed to create temp file${RC}"
		exit 1
	}
	trap 'rm -f "$tmp"' EXIT

	if jq -R -s --arg key "$KEY_NAME" '{ ($key): (split("\n") | map(select(length > 0))) }' "$SRC_FILE" >"$tmp"; then
		mv -f "$tmp" "$TARGET_JSON"
		trap - EXIT
		echo -e "${CYAN}:: $TARGET_JSON was successfully created!${RC}"
		rm_src_confirm
	else
		echo -e "${RED}:: jq failed to build json${RC}"
		exit 1
	fi
}

check_depends
if _confirm "Jsonify $SRC_FILE -> $TARGET_JSON?"; then
	main
else
	echo -e "${YELLOW}:: Script exited with code: (0)${RC}"
	exit 0
fi
