#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in post-fs-data mode

# CLEAR THE CACHE
rm -rf /data/magisk_backup_*
rm -rf /data/resource-cache/*
rm -rf /data/system/package_cache/*
rm -rf /cache/*
rm -rf /data/dalvik-cache/*

# CLEAN WIFI LOG
touch /data/vendor/wlan_logs
chmod 000 /data/vendor/wlan_logs
rm -rf /data/vendor/wlan_logs

# DISABLING IOSTAT FOR F2FS
echo 0 > /sys/fs/f2fs_dev/mmcblk0p79/iostat_enable

# DISABLE SCHEDULING STATISTICS
echo 0 > /proc/sys/kernel/sched_schedstats

# DISABLE CERTAIN SCHEDULER LOGGING AND STATISTICS
if [ -e "/proc/sys/kernel/sched_schedstats" ]; then
    echo 0 > /proc/sys/kernel/sched_schedstats
fi
echo "0 0 0 0" > /proc/sys/kernel/printk
echo "off" > /proc/sys/kernel/printk_devkmsg
for queue in /sys/block/*/queue; do
    echo 0 > "$queue/iostats"
done

# DISABLE XIAOMI PROGRAM DEBUGGING
resetprop sys.miui.ndcd off

sleep 1
# Sync before execute to avoid crashes
sync


