#!/usr/bin/env bash
set -e

################
##### mksh #####
################

# A script to create a bash script on the fly.
# Usage: ~/path/to/mksh.sh "script_name.sh" "$HOME/path/to/script_directory"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

logger_success() {
	echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

logger_error() {
	echo -e "${RED}[ERR]${NC} $1" >&2
}

script_name="$1"
script_path="$2"

if [[ -z "$script_name" ]]; then
	logger_error "Please provide a name for the script as first argument"
	exit 1
fi

if [[ -z "$script_path" ]]; then
	logger_error "Please provide a path for the script as second argument."
	exit 1
fi

created_script="$script_path/$script_name"
mkdir -p "$script_path"

if echo "#!/usr/bin/env bash" >"$created_script"; then
	chmod +x "$created_script"
	chmod 700 "$created_script"
else
	logger_error "Failed to create script"
	exit 1
fi

logger_success ":: Done."
