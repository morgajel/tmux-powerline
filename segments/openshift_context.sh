# shellcheck shell=bash
TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE:-name_namespace}"
TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL:-󱃾}"
TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL_COLOUR:-255}"
TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR:-󰿟}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Openshift config context display mode {"name_namespace", "name", "namespace"}.
# export TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE}"
# Openshift config context symbol.
# export TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL}"
# Openshift config context symbol colour.
# export TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL_COLOUR}"
# Separator for display mode "name_namespace"
# TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	if ! type oc >/dev/null 2>&1; then
		return 0
	fi
	oc_context=$(oc config current-context)
	oc_whoami=$(oc whoami)
	if [ -z "$oc_context" ]; then
		return 0
	fi
	oc_display="#[${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL}#[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]"
	if [ "${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE}" = "name" ]; then
		echo -n "${oc_display}${oc_context}"
	else
		#       CURRENT NAME   CLUSTER AUTHINF NAMESPACE
		read -r _unused oc_name oc_cluster _unused oc_namespace < <(oc config get-contexts "${oc_context}" --no-headers)
		oc_namespace="${oc_namespace:-default}"
		if [ "${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE}" = "namespace" ]; then
			echo -n "${oc_display} ${oc_namespace}"
		elif [ "${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE}" = "name_namespace" ]; then
			echo -n "${oc_display}${oc_name}${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR} ${oc_namespace}"
		elif [ "${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE}" = "full" ]; then
			echo -n "${oc_context}${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR} ${oc_namespace}@${oc_cluster} ${oc_display}${oc_whoami}"
		fi
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE" ]; then
		export TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL_COLOUR" ]; then
		export TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL_COLOUR}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR" ]; then
		export TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR="${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR}"
	fi
}
