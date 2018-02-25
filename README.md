Cheat Buffer is a plugin that will display help information in the `minibuffer` for you when you activate it.

It displays help by taking in the current command typed into the prompt and running a help command (by default it runs the [`cheat` plugin](https://github.com/chrisallenlane/cheat)).

[![asciicast](https://asciinema.org/a/rn0knw2tWsvZvAGQcSHOqDDwL.png)](https://asciinema.org/a/rn0knw2tWsvZvAGQcSHOqDDwL)

# Installation

`brew install cheat`

`git clone $URL "$HOME/.oh-my-zsh/custom/plugins"`

Lastly, you need to activate the plugin by adding in the `cheatbuffer` plugin to `~/.zshrc`:

```bash
plugins=(
  # other plugins
  cheatbuffer
)
```

# Modifiable environment variables

The current list of environment variables are:

```bash
# maximum buffer lines to show
export CHEATBUFFER_MAX_LINES=20
# use the cheat command as help
export CHEATBUFFER_COMMAND='cheat'
# key bind to activate cheatbuffer, defaults to ctrl + h
export CHEATBUFFER_KEY_SEQ='^h'
```