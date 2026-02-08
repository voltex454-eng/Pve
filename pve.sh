#!/bin/bash
# ==== Proxmox VE 9 Installer (No Subscription) on Debian 13 (Trixie) ====

# 1. Update system
echo "🔄 Updating system..."
apt update && apt full-upgrade -y

# 2. Install prerequisites
echo "📦 Installing prerequisites..."
apt install -y wget gnupg2

# 3. Add Proxmox VE 9 no-subscription repository
echo "➕ Adding Proxmox VE 9 no-subscription repo..."
# Note: Ensure "trixie" repo exists explicitly before running this in production
echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list

# 4. Add Proxmox VE 9 GPG key
echo "🔑 Adding GPG key..."
wget https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg

# 5. Update package lists
apt update

# 6. Install Proxmox VE + postfix + open-iscsi
echo "⚙️ Installing Proxmox VE core packages..."
DEBIAN_FRONTEND=noninteractive apt install -y proxmox-ve postfix open-iscsi

# 7. Fix SSL/certs for browser access (self-signed)
echo "🔒 Fixing SSL certificates..."
pvecm updatecerts --force
systemctl restart pveproxy

# 8. Clean up apt
echo "🧹 Cleaning up unused packages..."
apt autoremove -y

# 9. Remove Enterprise & Duplicate Repos (NEW STEP)
echo "🚫 Removing broken enterprise and duplicate repos..."
# Remove the broken enterprise file
rm -f /etc/apt/sources.list.d/pve-enterprise.sources
# Double-check for any leftover enterprise files
rm -f /etc/apt/sources.list.d/pve-enterprise.list
# Remove one of the duplicate files (keep only one)
rm -f /etc/apt/sources.list.d/pve-no-sub.list
# Clean and refresh repositories again
apt clean
apt update

# 10. Finished message
IP=$(hostname -I | awk '{print $1}')
echo "✅ Proxmox VE 9 (No subscription) installed successfully on Debian 13!"
echo "👉 Access web UI: https://${IP}:8006"
echo "🔑 Login with user: root and your system password."
