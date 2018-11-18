#!/usr/bin/env zsh

## Defaults
# maximum buffer lines to show
export CHEATBUFFER_MAX_LINES="${CHEATBUFFER_MAX_LINES:-40}"
# key bind to activate cheatbuffer, defaults to ctrl + h
export CHEATBUFFER_KEY_SEQ="${CHEATBUFFER_KEY_SEQ:-^h}"
export CHEATBUFFER_FUNC_ORDER="${CHEATBUFFER_FUNC_ORDER:-_cheatbuffer_help _cheatbuffer_cheat}"

cheatbuffer() {
	set -o pipefail

	local cheat_functions=($=CHEATBUFFER_FUNC_ORDER)

	for f in ${cheat_functions[@]}; do
		OUTPUT=$(eval "$f '$BUFFER' '$LBUFFER' '$RBUFFER'")
		if ! [ -z "$OUTPUT" ]; then
			break
		fi
	done

	if [ -z "$OUTPUT" ]; then
		zle -M "Couldn't find any help"
		return 1
	fi

	local PAGE=$(echo "$OUTPUT" | col -bx | head -n "$CHEATBUFFER_MAX_LINES") 2> /dev/null
	if [[ $? != 0 ]] ; then
		zle -M "Could not get head data from output"
		return 2
	fi

	local PAGE_LINES=$(echo "$PAGE" | wc -l)
	if [[ "$PAGE_LINES" -ge "$CHEATBUFFER_MAX_LINES" ]] ; then
		PAGE=$(printf "$PAGE\n...")
	fi

	# Print out the man page into the minibuffer
	zle -M "$PAGE"
}

###
### Methods
###
# These are the different functions that are available for cheatbuffer to use to provide help
# functions should take in three variables:
# BUFFER=$1
# LBUFFER=$2
# RBUFFER$3
# and output help.
#
# If no help is output, then cheatbuffer should try the next function
# https://stackoverflow.com/questions/20361398/bash-array-of-functions

# Tries to display "$CMD --help"
# Note this can also deal with subcommands too
# e.g. "nova --help" and "nova list --help"
#
# This function tries to get help starting with the first argument
# and tries the next argument until it can't get anymore help
_cheatbuffer_help() {
	local BUFFER="$1"

	local WORD_ARRAY=($=BUFFER)
	# get the longest substring that has help
	local CURRENT_COMMAND=''
	local FINAL_OUTPUT=''
	for ((i=1; i<= ${#WORD_ARRAY[@]}; i++ )); do
		# get a substring from 0 to the "i"th word
		CURRENT_COMMAND=${WORD_ARRAY[@]:0:$i}

		# Some things (like "man") output their help on stderr
		# so redirect stderr to stdout and then check the output
		local OUTPUT=$(eval "$CURRENT_COMMAND --help") 2> /tmp/.cheatbuffer_help_stderr
		if [ -z "$OUTPUT" ]; then
			OUTPUT=$(cat /tmp/.cheatbuffer_help_stderr)
		fi
		if [ -z "$OUTPUT" ]; then
			break
		fi
		FINAL_OUTPUT="$OUTPUT"
	done
	echo "$FINAL_OUTPUT"
}

# Tries to use the "cheat" command
# i.e. "cheat $CMD"
_cheatbuffer_cheat() {
	local BUFFER="$1"
	local LBUFFER="$2"
	local RBUFFER="$3"

	# Not sure what the best way to express that cheat is not installed
	# Right now this will just exit silently and go onto the next function
	if ! type cheat &> /dev/null ; then
		return 0
	fi

	# get the word that the cursor is over
	local CMD="${LBUFFER/* /}${RBUFFER/ */}"
	# If there are any quotes around the command (e.g. 'man) remove them
	CMD=$(echo "$CMD" | sed 's/^['\''"]*//g; s/['\''"]*$//g')

	local OUTPUT=$(cheat "$CMD") 2> /dev/null

	echo $OUTPUT
}

bindkey $CHEATBUFFER_KEY_SEQ cheatbuffer
zle -N cheatbuffer
