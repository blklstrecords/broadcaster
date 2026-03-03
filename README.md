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

Make sure the script is executed as root.

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
