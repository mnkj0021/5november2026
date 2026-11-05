# DifSync Windows setup

Temporary page for copying the DifSync installer command to another Windows computer.

## Install from Windows PowerShell

Open **Windows PowerShell** on the target computer and paste this **single line**:

```powershell
$script = Join-Path $env:TEMP 'difsync-install.ps1'; Invoke-WebRequest 'https://difsync.com/install/windows.ps1' -UseBasicParsing -OutFile $script -ErrorAction Stop; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script -PairCode (Read-Host 'Enter DifSync pairing code')
```

When prompted, enter your current DifSync pairing code. The code is intentionally **not** saved in this public repository. Use an elevated PowerShell window if the installer requires administrator privileges.

This downloads and runs the installer hosted at `https://difsync.com/install/windows.ps1`. Only run it if you trust that endpoint. The endpoint's live availability has not been verified from this repository.

### Notes

- No Git, Node.js, or repository clone is needed on the target PC. PowerShell comes with Windows.
- The command uses the Windows temporary folder and launches the downloaded script with the supplied pairing code.
- Pairing codes may expire or be single-use. Generate a fresh code if necessary.
- This README is only a shortcut to the installer, **not** a copy of the installer itself.
