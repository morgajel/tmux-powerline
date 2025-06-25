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
    oc_cluster=$(oc config view -o jsonpath="{.contexts[?(@.name==\"${oc_context}\")].context.cluster}" )
    oc_server=$(oc config view -o jsonpath="{$.clusters[?(@.name==\"${oc_cluster}\")].cluster.server}"|sed -e 's/https:..api\.//' -e 's/\..*//')
    oc_whoami=$(oc whoami)
    oc_kubeconfig=$(tmux display-message -p '#{e:KUBECONFIG}')
    if [ -z "$oc_context" ]; then
        return 0
    fi
    oc_display="#[${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SYMBOL}#[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]"
    #        CURRENT NAME   CLUSTER AUTHINF NAMESPACE
    read -r _unused oc_name oc_cluster _unused oc_namespace < <(oc config get-contexts "${oc_context}" --no-headers)
    oc_namespace="${oc_namespace:-default}"
    if [ "${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE}" = "namespace" ]; then
        echo -n "${oc_display} ${oc_namespace}"
    elif [ "${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE}" = "name_namespace" ]; then
        echo -n "${oc_display}${oc_name}${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR} ${oc_namespace}"
    elif [ "${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_DISPLAY_MODE}" = "full" ]; then
        local output_string="${oc_display}${oc_context}${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR} ${oc_display}${oc_namespace}"
        local joined_kubeconfig_basenames=""
        if [ -n "$oc_kubeconfig" ]; then # Only process if KUBECONFIG is set
            IFS=':' read -ra kubeconfig_paths <<< "$oc_kubeconfig" # Split by colon
            local basenames=()
            for p in "${kubeconfig_paths[@]}"; do
                if [ -n "$p" ]; then # Ensure path is not empty (e.g., from leading/trailing/double colons)
                    basenames+=("$(basename "$p")") # Extract basename for each path
                fi
            done
            joined_kubeconfig_basenames=$(IFS='+'; echo "${basenames[*]}") # Join with '+' for display
        fi

        if [ -n "$joined_kubeconfig_basenames" ]; then # Only display if basenames were found
            output_string+=" ${TMUX_POWERLINE_SEG_OPENSHIFT_CONTEXT_SEPARATOR} "
            output_string+="#[fg=245]Kubeconf: " # Label in light grey
            output_string+="#[fg=108]${joined_kubeconfig_basenames}" # Basename(s) in light green
        fi
        echo -n "$output_string" # Use echo -n as tmux-powerline expects raw output
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

