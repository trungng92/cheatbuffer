`cheatbuffer` is a zsh plugin that displays command help info in the `minibuffer` (the buffer below the prompt that is used by tab completion, reverse history search, etc).

When you activate `cheatbuffer` (`ctrl + h` by default), it will display help text by:

1. reading the current command
1. trying a host of help commands (by default it tries to run the command with `--help` and if not successful, the [`cheat` plugin](https://github.com/chrisallenlane/cheat))
1. displaying the help in the `minibuffer`.

![cheatbuffer demo](cheatbuffer-demo.gif)
[asciinema link](https://asciinema.org/a/qNF7bKdwHtoFmhiu3X6OYbR37)

# Installation

## Dependencies

**Required**
- [oh-my-zsh](http://ohmyz.sh/)

**Optional**
- [brew](https://brew.sh/)
- [cheat](https://github.com/chrisallenlane/cheat) (installed through brew with `brew install cheat`)

## Installing

1. `git clone https://github.com/trungng92/cheatbuffer.git "$HOME/.oh-my-zsh/custom/plugins/cheatbuffer"`
1. add the `cheatbuffer` plugin in the plugins list `$HOME/.zshrc`:

```bash
plugins=(
  # other plugins
  cheatbuffer
)
```

**Note: If you don't install the cheat plugin, this will only perform --help functionality**

# Modifiable environment variables

The current list of environment variables are:

```bash
# maximum buffer lines to show
export CHEATBUFFER_MAX_LINES=30
# Space separated function names that will be called when you try to run cheatbuffer
# by default we call _cheatbuffer_help and _cheatbuffer_cheat (which are defined in the cheatbuffer plugin).
# However, you are also able to add your own custom functions by modifying this variable
export CHEATBUFFER_FUNC_ORDER='_cheatbuffer_help _cheatbuffer_cheat'
# key bind to activate cheatbuffer, defaults to ctrl + h
export CHEATBUFFER_KEY_SEQ='^h'
```

# Example: Modifying cheatbuffer to use `man`

You can run these lines to make the minibuffer to show the `man` page:

```
# for docs on how to write a custom function, look inside cheatbuffer.plugin.zsh
man_example() {
    local BUFFER="$1"
    # man prints the help text to stderr
    OUTPUT=$(eval "man $BUFFER") 2>&1
    echo "$OUTPUT"
}

export CHEATBUFFER_FUNC_ORDER='man_example _cheatbuffer_help _cheatbuffer_cheat'
```

And when you press `ctrl + h` (or whatever `CHEATBUFFER_KEY_SEQ` is set to), it will display the `man` page instead.

# More info on how zsh plugin works

You can find documentation on [widgets here](http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets).

# Possible future features

- cycling through multiple help commands (or aggregating multiple help commands?)
