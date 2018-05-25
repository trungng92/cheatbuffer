#!/usr/bin/env zsh

## Defaults
# maximum buffer lines to show
export CHEATBUFFER_MAX_LINES="${CHEATBUFFER_MAX_LINES:-20}"
# use the cheat command as help
# Note that in the default value we have to have a \ to escape the $
# but when exporting the variable, you don't need to have the \
export CHEATBUFFER_COMMAND="${CHEATBUFFER_COMMAND:-cheat \$CMD}"
# key bind to activate cheatbuffer, defaults to ctrl + h
export CHEATBUFFER_KEY_SEQ="${CHEATBUFFER_KEY_SEQ:-^h}"

cheatbuffer() {
	set -o pipefail

	if ! echo "$CHEATBUFFER_COMMAND" | grep -w '$CMD' > /dev/null ; then
		zle -M "Cheatbuffer command '$CHEATBUFFER_COMMAND' requires literal string for variable '\$CMD'"
		return 1
	fi

	# get the word that the cursor is over
	CMD="${LBUFFER/* /}${RBUFFER/ */}"
	# If there are any quotes around the command (e.g. 'man) remove them
	CMD=$(echo "$CMD" | sed 's/^['\''"]*//g; s/['\''"]*$//g')

	# eval the cheatbuffer command so that we can evaluate the literal $CMD
	EVAL_COMMAND=$(eval echo "$CHEATBUFFER_COMMAND")

	# Only check the word that the cursor is on (the cheat buffer command can be more than one word)
	if ! type "$CMD" > /dev/null ; then
		zle -M "Could not validate '$CMD' with 'type $CMD'"
		return 2
	fi

	PAGE=$(eval "$EVAL_COMMAND" | col -b | head -n "$CHEATBUFFER_MAX_LINES") 2> /dev/null
	if [[ $? != 0 ]] ; then
		zle -M "Could not run command 'eval \"$EVAL_COMMAND\" | col -b | head -n \"$CHEATBUFFER_MAX_LINES\"' or no help page found for command '$CMD'"
		return 3
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
