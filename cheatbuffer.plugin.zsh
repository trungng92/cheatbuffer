#!/usr/bin/env zsh

## Defaults
# maximum buffer lines to show
export CHEATBUFFER_MAX_LINES="${CHEATBUFFER_MAX_LINES:-40}"
# key bind to activate cheatbuffer, defaults to ctrl + h
export CHEATBUFFER_KEY_SEQ="${CHEATBUFFER_KEY_SEQ:-^h}"

cheatbuffer() {
	set -o pipefail

	local WORD_ARRAY=($=BUFFER)

	# get the longest substring that has help
	local CURRENT_COMMAND=''
	for i in $(seq `echo ${#WORD_ARRAY[@]}`); do
		CURRENT_COMMAND=${WORD_ARRAY[@]:0:$i}
		if ! eval "$CURRENT_COMMAND -h" > /dev/null 2>&1; then
			break
		fi
		local CMD="$CURRENT_COMMAND"
	done

	if [ -z "$CMD" ]; then
		zle -M "Could not find any help command in '$BUFFER'"
		return 2
	fi

	# eval the cheatbuffer command so that we can evaluate the literal $CMD
	local EVAL_COMMAND=$(eval echo "$CMD -h")

	# # Only check the word that the cursor is on (the cheat buffer command can be more than one word)
	# if ! type "$CMD" > /dev/null ; then
	# 	zle -M "Could not validate '$CMD' with 'type $CMD'"
	# 	return 2
	# fi

	local PAGE=$(eval "$EVAL_COMMAND" | col -b | head -n "$CHEATBUFFER_MAX_LINES") 2> /dev/null
	if [[ $? != 0 ]] ; then
		zle -M "Could not run command 'eval \"$EVAL_COMMAND\" | col -b | head -n \"$CHEATBUFFER_MAX_LINES\"' or no help page found for command '$CMD'"
		return 3
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
	for i in $(seq `echo ${#WORD_ARRAY[@]}`); do
		# get a substring from 0 to the "i"th word
		CURRENT_COMMAND=${WORD_ARRAY[@]:0:$i}
		local OUTPUT=$(eval "$CURRENT_COMMAND --help") 2> /dev/null
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
	if ! type cheat; then
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
