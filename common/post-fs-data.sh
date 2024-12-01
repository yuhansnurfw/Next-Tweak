#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in post-fs-data mode

echo 0 | tee /sys/block/sd[a-g]/queue/iostats
echo 0 > /sys/block/mmcblk0/queue/iostats
echo mq-deadline > /sys/block/mmcblk0/queue/scheduler
echo deadline | tee /sys/block/sd[a-g]/queue/scheduler
echo 2 | tee /sys/block/loop[0-7]/queue/nomerges
echo 2 > /sys/block/zram0/queue/nomerges
echo 2 | tee /sys/block/sd[a-g]/queue/nomerges
echo 2 > /sys/block/mmcblk0/queue/nomerges
echo 1 | tee /sys/block/sd[a-g]/queue/rq_affinity
echo 1024 | tee /sys/block/sd[a-g]/queue/read_ahead_kb
echo 1024 > /sys/block/mmcblk0/queue/read_ahead_kb
echo 1024 | tee /sys/block/dm-[0-3]/queue/read_ahead_kb
for i in /sys/class/devfreq/1d84000.ufshc ; do
    chmod 666 $i/governor
    echo performance > $i/governor
sleep 2
    echo userspace > $i/governor
    chmod 444 $i/governor
done ;

#zram
for zram in /sys/block/zram{0,1}/queue; do
    echo 2048 > "$zram/read_ahead_kb"
done

#loop
for i in $(seq 0 53)
do
   echo 2048 > /sys/block/loop$i/queue/read_ahead_kb
done

device_config reset trusted_defaults device_idle
device_config put device_idle light_after_inactive_to 30000
device_config put device_idle light_idle_to 300000
device_config put device_idle light_idle_factor 2
device_config put device_idle light_max_idle_to 900000
device_config put device_idle light_idle_maintenance_min_budget 30000
device_config put device_idle light_idle_maintenance_max_budget 60000
device_config put device_idle min_light_maintenance_time 5000
device_config put device_idle min_deep_maintenance_time 30000
device_config put device_idle inactive_to 0
device_config put device_idle sensing_to 0
device_config put device_idle locating_to 0
device_config put device_idle motion_inactive_to 0
device_config put device_idle motion_inactive_to_flex 0
device_config put device_idle idle_after_inactive_to 900000
device_config put device_idle idle_pending_to 60000
device_config put device_idle max_idle_pending_to 120000
device_config put device_idle idle_pending_factor 2
device_config put device_idle idle_to 1800000
device_config put device_idle max_idle_to 21600000
device_config put device_idle idle_factor 2
device_config put device_idle min_time_to_alarm 300000
device_config put device_idle max_temp_app_allowlist_duration_ms 180000
device_config put device_idle wait_for_unlock true
setprop debug.hwui.render_dirty_regions false

exit 0
