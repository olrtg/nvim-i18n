<!-- markdownlint-disable MD033 MD041-->
<h3 align="center">
  nvim-i18n
</h3>

<p align="center">
  A plugin to improve your workflow with i18n.
</p>

<!-- prettier-ignore-start -->
> [!WARNING]
> **nvim-i18n** is still in early stages of development.
<!-- prettier-ignore-end -->

# Installation

**[lazy.nvim](https://github.com/folke/lazy.nvim)**

```lua
{ "olrtg/nvim-i18n", dependencies = "MunifTanjim/nui.nvim", config = true },
```

# Usage

```
:I18n
```

You can navigate with h/j/k/l, `H` for closing all nodes, `L` for opening all nodes, `Enter` for opening nodes or editing translations.

# Features

- [x] Locales directory detection
- [x] Read/Write JSON support
- [ ] Read/Write YAML support
- [ ] Automatic translations based on a language
- [ ] Conceal keys with their translations (don't know if conceals can be updated in real time)

Framework support:

- [ ] react-i18next. For normal `t('some.key')` seems to be working fine, no idea with `<Trans />`.

# Motivation

I often work with translations files and since I've migrated to neovim (early 2022) the only missing piece to stay forever in neovim is a i18n plugin. Visual Studio Code has one called [i18n-ally](https://github.com/lokalise/i18n-ally) which it's f\*cking great and I sometimes just hate opening vscode to use that plugin.

This is my attempt of building something like that but for neovim. I'm fairly new when it comes to plugin development (this is my second plugin) but since I don't see anyone building something like this I've decided to take matters into my own hands.

Hope you enjoy it!
