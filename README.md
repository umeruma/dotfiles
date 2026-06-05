# dotfiles

## install

### macOS / Linux

```bash
bash -c "$(curl -fsSL https://dot.umeru.ma/install)"
```

### Windows

Before running the install script, enable **Developer Mode** (required for symlink creation).

You can open the Settings page directly with this command in PowerShell:

```powershell
Start-Process "ms-settings:developers"
```

In **PowerShell**:

```powershell
irm https://dot.umeru.ma/install-win | iex
```

This will clone the repository to `~/Codes/dotfiles` and set up your dotfiles.

## docs

[dot.umeru.ma](https://dot.umeru.ma)
