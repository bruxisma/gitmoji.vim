# Overview

This is a simple pure VimL plugin for using [gitmoji](https://gitmoji.dev) from
within Vim. Specifically, it offers `iabbrev` replacements for the emoji
themselves, autocomplete, and aliases for *some* gitmoji.

Each of these (with the exception of autocomplete) are configurable.
Autocomplete is *always* enabled when the filetype is set to `gitcommit`.

gitmoji.vim currently requires the `matchfuzzy()` vim function. This was added
in September of 2020.

# Installation

gitmoji.vim uses the typical "module" package layout of a vim plugin. Simply
add it with your favorite plugin manager. For example, using
[`vim-plug`](https://github.com/junegunn/vim-plug):

```vim
Plug 'slurps-mad-rips/gitmoji.vim'
```

## Configuration

TODO
