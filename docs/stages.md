# Router-lib Stages

Router-lib uses **stages** to separate safe testing from full production deployment.

## Stage‑1 (Internal Testing)
- ✅ LAN zones prepared
- ✅ Optional DMZ zones prepared
- ✅ Internal firewall rules applied (LAN ↔ DMZ)
- ✅ DHCP/DNS services can run internally
- ❌ WAN zone not activated
- ❌ NAT disabled
- ❌ No external routing or internet access

**Use case:** Safe sandbox for validating firewall rules, DHCP leases, and zone isolation without interfering with your existing network or ISP modem.

---

## Stage‑2 (Full Deployment)
- ✅ LAN zones prepared
- ✅ DMZ zones prepared
- ✅ WAN zone activated
- ✅ NAT enabled for internet access
- ✅ Firewall rules expanded to cover WAN traffic
- ✅ External routing configured (default route to WAN)
- ✅ Internet‑facing services (VPN, port forwarding, monitoring) available

**Use case:** Production router with full connectivity, suitable for home, lab, or server deployment.

---

## Quick Comparison

| Feature/Service       | Stage‑1 (Testing) | Stage‑2 (Deployment) |
|------------------------|------------------|----------------------|
| LAN zones              | ✅ Enabled        | ✅ Enabled            |
| DMZ zones              | ✅ Enabled        | ✅ Enabled            |
| Firewall (internal)    | ✅ Enabled        | ✅ Enabled + WAN rules|
| DHCP/DNS               | ✅ Optional       | ✅ Optional           |
| WAN zone               | ❌ Not prepared   | ✅ Enabled            |
| NAT                    | ❌ Disabled       | ✅ Enabled            |
| External routing       | ❌ Disabled       | ✅ Default route set  |
| Internet services      | ❌ Skipped        | ✅ Active             |

