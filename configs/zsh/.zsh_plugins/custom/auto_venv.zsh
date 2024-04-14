# Function to check if the specified directory contains a 'venv' or '.venv' folder
function contains_venv {
	[[ -d "$1/venv" || -d "$1/.venv" ]]
}

# Function to check if the virtual environment is activated
function is_venv_activated {
	[[ -n "$VIRTUAL_ENV" ]]
}

# Function to activate the virtual environment
function activate_venv {
	source "$1/venv/bin/activate" 2>/dev/null || source "$1/.venv/bin/activate" 2>/dev/null
}

# Function to deactivate the virtual environment
function deactivate_venv {
	deactivate 2>/dev/null
}

# Function to handle changing directories
function chpwd_hook {
	local root_dir

	if git rev-parse --is-inside-work-tree &>/dev/null; then
		root_dir=$(git rev-parse --show-toplevel)
	else
		root_dir=$(pwd)
	fi

	if contains_venv "$root_dir"; then
		if is_venv_activated; then
			# Check if the activated venv is the same as the current folder venv
			if [[ "$VIRTUAL_ENV" != "$(realpath "$root_dir/venv")" && "$VIRTUAL_ENV" != "$(realpath "$root_dir/.venv")" ]]; then
				deactivate_venv
				activate_venv "$root_dir"
			fi
		else
			activate_venv "$root_dir"
		fi
	else
		deactivate_venv
	fi
}

# Activate hook function
autoload -U add-zsh-hook
add-zsh-hook chpwd chpwd_hook
