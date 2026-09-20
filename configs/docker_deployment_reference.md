# Docker Deployment Reference

## Environment

- Docker Desktop for Windows, WSL2 backend
- "Enable host networking" turned on (Settings → Resources → Network) — required for
  SafeLine's `tengine` service, which runs with `network_mode: host`

## DVWA

```bash
docker run -d -p 8888:80 --name dvwa vulnerables/web-dvwa
```

Note: mapped to host port 8888 instead of 8080 to avoid a local port conflict.
After first start, visit `http://localhost:8888/setup.php` and click
**Create / Reset Database** before logging in (default creds: admin / password).

## SafeLine WAF

Installed via the official Chaitin Tech deployment script, run from a WSL2 Ubuntu
shell (not PowerShell — the script requires a Linux environment):

```bash
bash -c "$(curl -fsSLk https://waf.chaitin.com/release/latest/manager.sh)"
```

This deploys the full SafeLine container stack via Docker Compose to
`/data/safeline/docker-compose.yaml`, including:

| Container | Role |
|---|---|
| `safeline-mgt` | Management dashboard (port `9443` → `1443`) |
| `safeline-tengine` | Reverse proxy / traffic inspection engine (`network_mode: host`) |
| `safeline-detector` | Attack detection engine |
| `safeline-luigi` | API/backend |
| `safeline-postgres` | Database |
| `safeline-chaos` | Supporting service |
| `safeline-fvm` | Supporting service |

Dashboard: `https://localhost:9443` (self-signed cert — accept the browser warning).
Initial admin password is generated during install; retrieve via the WSL install log
or the manager script's password-reset option if lost.

## Known infrastructure issues encountered

- **WSL2 NAT masks source IPs**: SafeLine's Attacks log shows all external attacker
  traffic (including from the Kali VM) as originating from `127.0.0.1`. Nginx's
  `X-Forwarded-For` config was verified correct — the IP loss happens at the WSL2
  NAT boundary before traffic reaches the container. Documented as a lab
  limitation, not fixed (would require moving off WSL2 to a native Linux host/VM).
- **Windows Firewall / network profile**: inbound rules had to be added for each
  exposed port (8888 for DVWA, 80/443 for the WAF), and the active network adapter
  had to be set to "Private" (not "Public") for inbound traffic from the Kali VM
  to reach the host at all.
- **Host LAN IP changes**: the Windows host's IP changes on reconnect; the SafeLine
  application's upstream address and both hosts files (`dvwa.lab` entry) needed
  updating each time this happened.

## Restart / stop (for reuse across sessions)

```bash
# Stop
docker stop dvwa safeline-tengine safeline-luigi safeline-mgt safeline-detector safeline-postgres safeline-chaos safeline-fvm

# Resume
docker start dvwa safeline-tengine safeline-luigi safeline-mgt safeline-detector safeline-postgres safeline-chaos safeline-fvm
```
