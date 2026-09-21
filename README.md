# webOS TV Developer CLI in Docker

Runs the official [`@webos-tools/cli`](https://www.npmjs.com/package/@webos-tools/cli) (the `ares-*`
commands) in a container, so no Node toolchain or SDK install is needed on the host.

## Layout

| Path            | Purpose                                                      |
| --------------- | ------------------------------------------------------------ |
| `Dockerfile`    | `node:20-bookworm-slim` plus the webOS CLI                   |
| `compose.yaml`  | Service definition and the volumes that hold device state    |
| `entrypoint.sh` | Fixes SSH key permissions, which a named volume mounts as 0755 |
| `webos.ps1`     | Wrapper for PowerShell                                       |
| `webos`         | Wrapper for POSIX shells                                     |
| `ipk/`          | Packages to install; mounted at `/work/ipk` in the container  |

Device registrations persist in the `webos-config` volume and the per-device SSH key in
`webos-ssh`, so a registered TV survives container and host restarts.

## Usage

```powershell
docker compose build            # once, or after changing CLI_VERSION

.\webos.ps1 ares-setup-device --list
.\webos.ps1 ares-install --device tv --list
.\webos.ps1                     # interactive shell in the container
```

## Registering a TV

Enable Developer Mode on the TV and turn on its **key server** button, then:

```powershell
.\webos.ps1 ares-setup-device --add tv --info '{\"host\":\"<TV_IP>\",\"port\":\"9922\",\"username\":\"prisoner\",\"default\":true}'
.\webos.ps1 ares-novacom --device tv --getkey
```

`--getkey` downloads the encrypted key to `/root/.ssh/<name>_webos` and then prompts for the
passphrase shown in the Developer Mode app. The prompt needs a real terminal; to register the
passphrase without one, write it straight into the device config:

```powershell
.\webos.ps1 ares-setup-device --modify tv --info '{\"privatekey\":\"tv_webos\",\"passphrase\":\"<PASSCODE>\"}'
```

The passphrase rotates whenever the TV's Developer Mode session is renewed, so re-run both steps
when authentication starts failing.

Verify with:

```powershell
.\webos.ps1 ares-novacom --device tv --run "uname -a"
```

## Installing an app

Drop the `.ipk` in `ipk/` and reference it by its container path:

```powershell
.\webos.ps1 ares-install --device tv /work/ipk/<package>.ipk
.\webos.ps1 ares-launch  --device tv <app-id>
.\webos.ps1 ares-install --device tv --remove <app-id>
```

webOS TVs are aarch64, so pick the `arm` build of a package when a release offers several.

## Networking

The container reaches the TV over the default bridge network; outbound LAN access is all the CLI
needs. Ports involved are 9922 (SSH) and 9991 (Developer Mode key server), both on the TV.
