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
