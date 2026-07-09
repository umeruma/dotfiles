# dotfiles

## install

### macOS / Linux

```bash
bash -c "$(curl -fsSL https://dot.umeru.ma/install)"
```

This clones to `~/Codes/dotfiles`, installs mise if needed, then runs `mise bootstrap` (packages, login shell, deploy). Optional GUI/CLI apps: `mise run install-apps`.

### Windows

On a fresh / reset Windows, install **App Installer** (winget) from the Microsoft Store first — it is the prerequisite for everything else. Git, PowerShell 7 and mise are then installed automatically by the script. (If winget is missing, the script opens the Store page for you and stops so you can install it.)

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
