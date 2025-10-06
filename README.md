# dotfiles

## install
This dotfiles repository is designed to be installed at `~/Codes/dotfiles`.

Review the contents of the script before running it:  
<a href="https://dot.umeru.ma/install" target="_blank" rel="noopener noreferrer">https://dot.umeru.ma/install</a>

Open Terminal.app, and run:

```
bash -c "$(curl -fsSL https://dot.umeru.ma/install)"
```
This will clone the repository to `~/Codes/dotfiles` and set up your dotfiles.

Notes on bash and curl options:

bash:
- `-c`: Execute the given string as a bash command (e.g., `bash -c "echo hello"` outputs `hello`).

curl:
- `-f` (`--fail`): Fail silently on server errors (no output, exit non-zero).
- `-s` (`--silent`): Silent mode — do not show progress meter or error messages.
- `-S` (`--show-error`): When used with `-s`, show error messages on failure (since `-s` alone is fully silent).
- `-L` (`--location`): Follow HTTP redirects automatically.

## macOS defaults
To update macOS defaults setting, run:

```
cd $DOTFILES && just defaults
```

## Terminal theme
To apply theme for macOS Terminal, run:
```
cd $DOTFILES && just theme
```

then looks like this:

<img alt="" src="https://i.gyazo.com/e6b46b2e0332ecbbf1e2fcf859533f3c.jpg">

<!-- ## homesick compatible

This repository is [homesick](https://github.com/technicalpickles/homesick) compatible. You can use homesick to manage these dotfiles:

```bash
# Install homesick
gem install homesick

# Clone and link dotfiles (will be installed to ~/Codes/dotfiles)
homesick clone umeruma/dotfiles
homesick link dotfiles

# Run setup script
homesick rc dotfiles
``` -->

## tech stack

- [just](https://github.com/casey/just#readme) as command runner
- [sheldon](https://github.com/rossmacarthur/sheldon#readme) as zsh plugin manager
- [Homebrew](https://docs.brew.sh/Manpage) as package manager
<!-- - [homesick](https://github.com/technicalpickles/homesick) compatible structure -->

## website

[dot.umeru.ma](https://dot.umeru.ma)
