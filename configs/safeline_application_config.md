# SafeLine WAF — Application Configuration Reference

Settings used when registering DVWA as a protected application in SafeLine.
(Dashboard: Applications → Add Application)

## Application: DVWA

| Field | Value |
|---|---|
| Domain | `dvwa.lab` |
| Listening Port | 80 (HTTP) |
| Mode | Reverse Proxy |
| Upstream | `http://<windows-host-lan-ip>:8888` |
| Application Name | DVWA |

**Notes:**
- Upstream IP is the Windows host's active LAN IP (Wi-Fi adapter) — this changes
  whenever the host reconnects to a network and must be updated in the Applications
  panel each time.
- HTTPS/SSL was scoped out for this lab (kept to HTTP only) to reduce setup surface;
  the SafeLine dashboard supports self-signed cert upload for HTTPS if needed.

## Local hosts file entries (both Windows host and Kali attacker VM)

```
<windows-host-lan-ip> dvwa.lab
```

Must be updated on **both** machines whenever the Windows host's LAN IP changes.
