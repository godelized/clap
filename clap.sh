read -r -d '' _clap_prelude <<EOF
# Clap input: configuration.
declare -A CLAP_cfg=(
	[name]=''
	[description]=''
)

# Clap input: flags.
declare -A CLAP_flags_def=()
declare -A CLAP_flags_def_alt=()
declare -A CLAP_flags_def_help=()

# Clap input: positional parameters.
declare -a CLAP_positionals_def=()
declare -A CLAP_positionals_def_help=()

# Clap output.
declare -A CLAP_flags=()
declare -a CLAP_positionals=()
EOF

eval "$_clap_prelude"

clap_parse() {
	local param

	# Flags.
	while [ $# -gt 0 ]; do
		param=$1
		param="${CLAP_flags_def_alt[$param]-$param}" # Look for an alternative flag first.
		# shellcheck disable=2154
		param="${CLAP_flags_def[$param]+$param}" # Fallback on the main flag.
		if [ -z "$param" ]; then
			break
		fi
		# shellcheck disable=2034
		CLAP_flags["$param"]=true
		shift
	done

	# Positional parameters.
	while [ $# -gt 0 ]; do
		param=$1
		CLAP_positionals+=("$param")
		shift
	done
}

clap_show_usage() {
	local -A all_flags

	# shellcheck disable=2154
	for flag in "${!CLAP_flags_def[@]}"; do
		all_flags[$flag]=$flag
	done

	# shellcheck disable=2154
	for alt in "${!CLAP_flags_def_alt[@]}"; do
		local flag="${CLAP_flags_def_alt[$alt]}"
		if [ -z "${all_flags[$flag]+$alt}" ]; then
			continue
		fi

		all_flags[$flag]+=", $alt"
	done

	printf '%s' "${CLAP_cfg[name]}"
	if [ ${#all_flags[@]} -gt 0 ]; then
		printf ' [<OPTIONS>]'
	fi
	# shellcheck disable=2154
	for param in "${CLAP_positionals_def[@]}"; do
		printf ' %s' "${param@U}"
	done
	printf '\n'

	if [ -n "${CLAP_cfg[description]}" ]; then
		printf '\n%s\n' "${CLAP_cfg[description]}"
	fi

	if [ ${#CLAP_positionals_def[@]} -gt 0 ]; then
		printf '\nPOSITIONAL PARAMETERS:\n\n'
		for param in "${CLAP_positionals_def[@]}"; do
			# shellcheck disable=2154
			printf '|%s|%s\n' "${param@U}" "${CLAP_positionals_def_help[$param]}"
		done | column -t -s '|' -c 80 -W 2
	fi

	if [ ${#all_flags[@]} -gt 0 ]; then
		printf '\nOPTIONS:\n\n'
		for flag in "${!all_flags[@]}"; do
			# shellcheck disable=2154
			printf '|%s|%s\n' "${all_flags[$flag]}" "${CLAP_flags_def_help[$flag]}"
		done | column -t -s '|' -c 80 -W 2
	fi
}
