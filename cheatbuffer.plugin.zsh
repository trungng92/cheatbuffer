#!/usr/bin/env zsh

## Defaults
# maximum buffer lines to show
export CHEATBUFFER_MAX_LINES="${CHEATBUFFER_MAX_LINES:-20}"
# use the cheat command as help
export CHEATBUFFER_COMMAND="${CHEATBUFFER_COMMAND:-cheat}"
# key bind to activate cheatbuffer, defaults to ctrl + h
export CHEATBUFFER_KEY_SEQ="${CHEATBUFFER_KEY_SEQ:-^h}"

cheatbuffer() {
	set -o pipefail

	# Split $BUFFER into the command and its arguments
	printf "$BUFFER" | read CMD ARGS

	if ! type "$CHEATBUFFER_COMMAND" > /dev/null ; then
		zle -M "Could not run help command '$CHEATBUFFER_COMMAND'"
		return 1
	fi

	PAGE=$($CHEATBUFFER_COMMAND $CMD | HEAD -n "$CHEATBUFFER_MAX_LINES") 2> /dev/null
	if [[ $? != 0 ]] ; then
		zle -M "No help page found for command '$CMD'"
		return 2
	fi

	PAGE_LINES=$(echo "$PAGE" | wc -l)
	if [[ "$PAGE_LINES" -ge "$CHEATBUFFER_MAX_LINES" ]] ; then
		PAGE=$(printf "$PAGE\n...")
	fi

	# Print out the man page into the minibuffer
	zle -M "$PAGE"
}

bindkey $CHEATBUFFER_KEY_SEQ cheatbuffer
zle -N cheatbuffer
