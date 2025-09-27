# dotfiles

## install
Open Termilal.app, and run:

```
bash -c "$(curl -fsSL https://dot.umeru.ma/install)"
```

<a href="https://dot.umeru.ma/install" target="_blank" rel="noopener noreferrer">View raw install script</a>

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
cd ~/.dotfiles && just defaults
```

## Terminal theme
To apply theme for macOS Termianl, run:
```
cd ~/.dotfiles && just theme
```

then looks like this:

<img alt="" src="https://i.gyazo.com/e6b46b2e0332ecbbf1e2fcf859533f3c.jpg">

## tech stack

- [just](https://github.com/casey/just#readme) as command runner
- [sheldon](https://github.com/rossmacarthur/sheldon#readme) as zsh plugin manager
- [Homebrew](https://docs.brew.sh/Manpage) as package manager

## website

[dot.umeru.ma](https://dot.umeru.ma)
