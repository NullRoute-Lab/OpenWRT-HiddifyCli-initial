#!/bin/sh

echo "Starting HiddifyCli cleanup process..."

# Step 1: Stop and Disable Hiddify Service
echo "Stopping and disabling Hiddify service..."
if [ -f /etc/init.d/hiddify ]; then
    /etc/init.d/hiddify stop
    /etc/init.d/hiddify disable
else
    echo "Service script /etc/init.d/hiddify not found. Skipping service stop/disable."
fi

# Step 2: Remove Service Script
echo "Removing service script..."
rm -f /etc/init.d/hiddify

# Step 3: Remove Root Files and Directories
echo "Removing files and directories from /root/..."
rm -f /root/hiddify-conf.json
rm -f /root/hiddify-openvpn-conf.json
rm -f /root/hiddify_watchdog.sh
rm -f /root/hiddify_openvpn_watchdog.sh
rm -f /root/hiddify-sub # Live configuration file
rm -rf /root/openvpn/

# Step 4: Remove Runtime Files and Directories
echo "Removing runtime files and directories..."
# Default SERVICE_DIR for RAM_MODE=true (as per current init script)
rm -rf /tmp/usr/bin/HiddifyCli
# Fallback for RAM_MODE=false or older setups
rm -rf /root/HiddifyCli
# Temporary configuration file
rm -f /tmp/hiddify-sub.new

# Step 5: Explicitly Ensure Cron Job Removal (Defensive Step)
echo "Ensuring Hiddify-related cron jobs are removed..."
# For new cron job format: /etc/init.d/hiddify update_config
(crontab -l 2>/dev/null | grep -v -F "/etc/init.d/hiddify update_config" | crontab -)
# For old cron job format: /etc/init.d/hiddify restart
(crontab -l 2>/dev/null | grep -v -F "/etc/init.d/hiddify restart" | crontab -)
# Also remove any reference to the watchdog scripts directly in crontab, just in case
(crontab -l 2>/dev/null | grep -v -F "hiddify_watchdog.sh" | crontab -)
(crontab -l 2>/dev/null | grep -v -F "hiddify_openvpn_watchdog.sh" | crontab -)


echo "HiddifyCli cleanup process completed."
echo "Note: Installed packages (coreutils-nohup, curl, kmod-tun, wget, jq) have not been removed as per requirements."

exit 0
