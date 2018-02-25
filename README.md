`cheatbuffer` is a zsh plugin that displays command help info in the `minibuffer` (the buffer below the prompt that is used by tab completion, reverse history search, etc).

When you activate `cheatbuffer` (`ctrl + h` by default), it will display help text by:

1. reading the current command typed into the prompt
1. running a help command (by default it runs the [`cheat` plugin](https://github.com/chrisallenlane/cheat))
1. displaying the help in the `minibuffer`.

[![asciicast](https://asciinema.org/a/QRZUuu7AmgXM9RMkHPxS5tG4j.png)](https://asciinema.org/a/QRZUuu7AmgXM9RMkHPxS5tG4j)

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