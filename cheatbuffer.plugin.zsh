#!/usr/bin/env zsh

## Defaults
# maximum buffer lines to show
export CHEATBUFFER_MAX_LINES="${CHEATBUFFER_MAX_LINES:-20}"
# use the cheat command as help
export CHEATBUFFER_COMMAND="${CHEATBUFFER_COMMAND:-cheat}"
# key bind to activate cheatbuffer, defaults to ctrl + h
export CHEATBUFFER_KEY_SEQ="${CHEATBUFFER_KEY_SEQ:-^h}"

cheatbuffer() {
	# Split $BUFFER into the command and its arguments
	printf "$BUFFER" | read CMD ARGS

	PAGE=$(cheat $CMD | HEAD -n "$CHEATBUFFER_MAX_LINES") 2> /dev/null
	if [[ $? != 0 ]] ; then
		zle -M "No help page found"
		return 1
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
