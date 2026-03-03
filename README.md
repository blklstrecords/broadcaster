# broadcaster

## Installation notes

The installer now creates a dedicated system account called `broadcaster` which
owns the program files and runs the stream service. Configuration lives under
`/etc/broadcaster` and is owned by `root:broadcaster` with restrictive
permissions; edit the environment file with `sudo` and the service will be able
to read it.

After running `install.sh` you'll have two units:
`broadcaster.service` (long–running stream monitor) and
`dns-update.timer`/`dns-update.service` (periodic Cloudflare updater).

Services are configured to run with `LANG=C.UTF-8` and `LC_ALL=C.UTF-8` so
notification text and logs are encoded consistently and display correctly on
Windows clients.

Make sure the script is executed as root.

## Windows guide (Icecast + Radio)

### 1) Install Icecast on Windows

1. Download and install Icecast for Windows (for example to
   `C:\Icecast`).
2. Copy this repository's Windows Icecast files into that installation:

- `windows\Icecast\icecast.xml` -> `C:\Icecast\icecast.xml`
- `windows\Icecast\web\*` -> `C:\Icecast\web\`

3. If prompted, overwrite existing files so the customized web pages and
   config are used.

### 2) Start Icecast

Option A (interactive, easiest):

- Open `cmd.exe` in `C:\Icecast`
- Run:

```bat
icecast.bat
```

Option B (background service with NSSM):

1. Download `nssm.exe` and place it somewhere permanent (for example
   `C:\nssm\nssm.exe`).
2. Install Icecast as a Windows service:

```bat
C:\nssm\nssm.exe install Icecast
```

Use these values in the NSSM UI:

- Application path: `C:\Icecast\bin\icecast.exe`
- Startup directory: `C:\Icecast`
- Arguments: `-c C:\Icecast\icecast.xml`

Then start and verify:

```bat
net start Icecast
sc query Icecast
```

Status URLs:

- http://localhost:8000/status.xsl
- http://localhost:8000/player.html

### 3) Radio folder scripts

The repository contains `windows\Radio\broadcaster.bat` and
`windows\Radio\recorder.bat`.

#### `broadcaster.bat`

Purpose: Ensure recording folder exists and control the Icecast service
(`start`, `stop`, `restart`).

Usage:

```bat
broadcaster.bat
broadcaster.bat stop
broadcaster.bat restart
```

Notes:

- Uses service name `Icecast`
- Uses recording folder `D:\Recordings`

#### `recorder.bat`

`recorder.bat` currently contains PowerShell content. Run it with
PowerShell:

```bat
powershell -ExecutionPolicy Bypass -File recorder.bat
```

For lock-safe file finalizing, `windows\Radio\finalize.ps1` is available.

### 4) Run Radio scripts with NSSM

You can keep Radio processes running in the background by creating NSSM
services.

Install service for `broadcaster.bat`:

```bat
C:\nssm\nssm.exe install BroadcasterCtl
```

NSSM values:

- Application path: `C:\Windows\System32\cmd.exe`
- Startup directory: `<repo>\windows\Radio`
- Arguments: `/c broadcaster.bat`

Install service for finalizer loop (`finalize.ps1`):

```bat
C:\nssm\nssm.exe install RecorderFinalize
```

NSSM values:

- Application path: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
- Startup directory: `<repo>\windows\Radio`
- Arguments: `-NoProfile -ExecutionPolicy Bypass -File finalize.ps1`

Start services:

```bat
net start BroadcasterCtl
net start RecorderFinalize
```

Tips:

- Set NSSM I/O redirection logs for easier troubleshooting.
- If your service account differs, ensure it has write access to
  `D:\Recordings`.

## Log

```
journalctl -u broadcaster.service -f
journalctl -u dns-update.service -f
```

## Status

```
systemctl status broadcaster
systemctl list-timers | grep dns-update
```

## Troubleshooting

- If you see frequent source reconnects every ~60 seconds, verify `LIMITER` in
  `/etc/broadcaster/broadcaster.env`. Empty limiter values are supported, but
  malformed custom filter values can cause ffmpeg to connect and exit quickly.
- Icecast warning `No charset found for "ISO8859-1"` is produced by the
  Icecast server charset modules, not by Windows clients. The broadcaster
  services run in UTF-8 mode (`C.UTF-8`) for Windows-compatible message text.
