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

	# get the word that the cursor is over
	CMD="${LBUFFER/* /}${RBUFFER/ */}"

	# replace the string '$CMD' with the actual value
	# (I could have used eval, but this makes more sense to me)
	EVAL_COMMAND=$(echo "$CHEATBUFFER_COMMAND" | sed "s|\$CMD|$CMD|g")

	# Only check the word that the cursor is on (the cheat buffer command can be more than one word)
	if ! type $(echo "$CMD") > /dev/null ; then
		zle -M "Could not run help command for '$CMD' in '$EVAL_COMMAND'"
		return 1
	fi

	PAGE=$(eval "$CHEATBUFFER_COMMAND | col -b | head -n $CHEATBUFFER_MAX_LINES") 2> /dev/null
	if [[ $? != 0 ]] ; then
		zle -M "Could not run command '$EVAL_COMMAND' or no help page found for command '$CMD'"
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
