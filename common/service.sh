#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode

file() {
  if [[ -f "$1" ]]; then
    return 0
  else
    return 1
  fi
}

read_file_unlock() {
  if file "$1"; then
    chmod 444 "$1"
    cat "$1"
  fi
}

write_file_lock() {
  if file "$1"; then
    chmod 666 "$1"
    echo "$2" > "$1"
    chmod 444 "$1"
  fi
}

read_file() {
  file="$1"
  if [ -f "$file" ] && [ ! -r "$file" ]; then
    chmod +r "$file"
  fi
  cat "$file"
}

write_file() {
  file="$1"
  content="$2"
  if [ -f "$file" ] && [ ! -w "$file" ]; then
    chmod +w "$file"
  fi
  echo "$content" > "$file"
}

while [[ -z "$(resetprop sys.boot_completed)" ]]; do
    sleep 1
done

 resetprop pm.dexopt.inactive speed
 resetprop dalvik.vm.dex2oat-filter speed
 resetprop dalvik.vm.image-dex2oat-filter speed
 resetprop pm.dexopt-filter speed
 resetprop pm.dexopt.first-boot speed
 resetprop pm.dexopt.boot speed
 resetprop pm.dexopt.install speed
 resetprop pm.dexopt.bg-dexopt speed
 resetprop pm.dexopt.install-filter speed
 resetprop pm.dexopt.nsys-library speed
 resetprop pm.dexopt.shared-apk speed
 resetprop pm.dexopt.forced-dexopt speed

# Function
set_param() {
    echo "$2" > "$1"
}


# Set core tweak
ps="/proc/sys/kernel"
    set_param "$ps/sched_schedstats" "0"
    set_param "$ps/perf_cpu_time_max_percent" "9"
    set_param "$ps/sched_walt_rotate_big_tasks" "2"
    set_param "$ps/sched_tunable_scaling" "0"
    set_param "$ps/sched_min_task_util_for_colocation" "35"
    set_param "$ps/sched_min_task_util_for_boost" "0"
    set_param "$ps/random/poolsize" "4096"
    set_param "$ps/sched_autogroup_enabled" "1"

# Mem tweaks
pv="/proc/sys/vm"
    set_param "$pv/min_free_kbytes" "32768"
    set_param "$pv/extra_free_kbytes" "31134"
    set_param "$pv/page-cluster" "0"
    set_param "$pv/reap_mem_on_sigkill" "0"
    set_param "$pv/block_dump" "0"
    set_param "$pv/oom_dump_tasks" "0"
    set_param "$pv/laptop_mode" "0"
    set_param "$pv/vfs_cache_pressure" "81"
    set_param "$pv/dirty_writeback_centisecs" "14640"
    set_param "$pv/dirty_expire_centisecs" "4880"
    set_param "$pv/dirty_ratio" "36"
    set_param "$pv/dirty_background_ratio" "12"
    set_param "$pv/max_map_count" "524288"
    set_param "$pv/stat_interval" "60"

# Network tweaks
pn="/proc/sys/net/ipv4"
    set_param "$pn/tcp_fastopen_key" "3"
    set_param "$pn/tcp_tw_reuse" "1"
    set_param "$pn/tcp_challenge_ack_limit" "9999"
    set_param "$pn/tcp_timestamps" "1"
    set_param "$pn/tcp_window_scaling" "1"
    set_param "$pn/tcp_keepalive_probes" "3"
    set_param "$pn/tcp_slow_start_after_idle" "0"
    set_param "$pn/tcp_synack_retries" "3"
    set_param "$pn/tcp_keepalive_intvl" "15"
    set_param "$pn/tcp_fin_timeout" "15"
    set_param "$pn/tcp_ecn" "1"

# Other tweaks
set_param /sys/module/cpu_input_boost/parameters/wake_boost_duration 270
set_param /sys/module/binder/parameters/debug_mask 0
set_param /dev/stune/top-app/schedtune.boost 30
set_param /sys/module/subsystem_restart/parameters/enable_ramdumps 0
set_param /sys/module/subsystem_restart/parameters/enable_mini_ramdumps 0
set_param /sys/class/kgsl/kgsl-3d0/acd 1
set_param /sys/class/kgsl/kgsl-3d0/force_no_nap 0
set_param /sys/class/kgsl/kgsl-3d0/throttling 0
set_param /dev/blkio/background/blkio.weight 150
set_param /sys/fs/f2fs/sda28/cp_interval 90
set_param /sys/fs/f2fs/sda28/ram_thresh 18
set_param /sys/module/workqueue/parameters/power_efficient 1
set_param /proc/sys/fs/dir-notify-enable 0
set_param /proc/sys/fs/leases-enable 1
set_param /proc/sys/fs/lease-break-time 10

write_file "/proc/sys/kernel/panic" "0"
  write_file "/proc/sys/kernel/panic_on_oops" "0"
  write_file "/proc/sys/kernel/panic_on_rcu_stall" "0"
  write_file "/proc/sys/kernel/panic_on_warn" "0"
  write_file "/sys/module/kernel/parameters/panic" "0"
  write_file "/sys/module/kernel/parameters/panic_on_warn" "0"
  write_file "/sys/module/kernel/parameters/panic_on_oops" "0"

  write_file "/proc/sys/kernel/printk" "0 0 0 0"
  write_file "/proc/sys/kernel/printk_devkmsg" "off"
  write_file "/sys/module/printk/parameters/console_suspend" "Y"
  write_file "/sys/module/printk/parameters/cpu" "N"
  write_file "/sys/module/printk/parameters/ignore_loglevel" "Y"
  write_file "/sys/module/printk/parameters/pid" "N"
  write_file "/sys/module/printk/parameters/time" "N"
  write_file "/sys/kernel/printk_mode/printk_mode" "0"

  find /sys/ -name "*log*" -o -name "*debug*" -o -name "*throttling*" | while IFS= read -r file; do
    write_file "$file" "0"
  done

  write_file "/proc/sys/kernel/sched_tunable_scaling" "1"

for sched in /sys/kernel/debug/sched_features/*; do
  write_file_lock "$sched" "NO_GENTLE_FAIR_SLEEPERS"
  write_file_lock "$sched" "NO_HRTICK"
  write_file_lock "$sched" "NO_DOUBLE_TICK"
  write_file_lock "$sched" "NO_RT_RUNTIME_SHARE"
  write_file_lock "$sched" "NO_TTWU_QUEUE"
  write_file_lock "$sched" "UTIL_EST"
  write_file_lock "$sched" "ARCH_CAPACITY"
done

write_file "/proc/sys/vm/drop_caches" "3"
  write_file "/proc/sys/vm/dirty_background_ratio" "20"
  write_file "/proc/sys/vm/dirty_expire_centisecs" "1000"
  write_file "/proc/sys/vm/page-cluster" "0"
  write_file "/proc/sys/vm/dirty_ratio" "10"
  write_file "/proc/sys/vm/laptop_mode" "0"
  write_file "/proc/sys/vm/block_dump" "1"
  write_file "/proc/sys/vm/compact_memory" "0"
  write_file "/proc/sys/vm/dirty_writeback_centisecs" "5000"
  write_file "/proc/sys/vm/oom_dump_tasks" "1"
  write_file "/proc/sys/vm/oom_kill_allocating_task" "0"
  write_file "/proc/sys/vm/stat_interval" "60"
  write_file "/proc/sys/vm/panic_on_oom" "0"
  write_file "/proc/sys/vm/swappiness" "20"
  write_file "/proc/sys/vm/vfs_cache_pressure" "50"
  write_file "/proc/sys/vm/overcommit_ratio" "80"
  write_file "/proc/sys/vm/extra_free_kbytes" "10240"
  write_file "/proc/sys/kernel/random/read_wakeup_threshold" "64"
  write_file "/proc/sys/kernel/random/write_wakeup_threshold" "128"
  
#disable log
find /sys/ -name debug_mask -exec sh -c 'echo "0" > "$1"' _ {} \;
find /sys/ -name debug_level -exec sh -c 'echo "0" > "$1"' _ {} \;
find /sys/ -name edac_mc_log_ce -exec sh -c 'echo "0" > "$1"' _ {} \;
find /sys/ -name edac_mc_log_ue -exec sh -c 'echo "0" > "$1"' _ {} \;
find /sys/ -name enable_event_log -exec sh -c 'echo "0" > "$1"' _ {} \;
find /sys/ -name log_ecn_error -exec sh -c 'echo "0" > "$1"' _ {} \;
find /sys/ -name snapshot_crashdumper -exec sh -c 'echo "0" > "$1"' _ {} \;

echo "NO_GENTLE_FAIR_SLEEPERS:1" >/sys/kernel/debug/sched_features
  echo "START_DEBIT:1" >/sys/kernel/debug/sched_features
  echo "NEXT_BUDDY:1" >/sys/kernel/debug/sched_features
  echo "LAST_BUDDY:1" >/sys/kernel/debug/sched_features
  echo "STRICT_SKIP_BUDDY:1" >/sys/kernel/debug/sched_features
  echo "CACHE_HOT_BUDDY:1" >/sys/kernel/debug/sched_features
  echo "WAKEUP_PREEMPTION:1" >/sys/kernel/debug/sched_features
  echo "NO_HRTICK:1" >/sys/kernel/debug/sched_features
  echo "NO_DOUBLE_TICK:1" >/sys/kernel/debug/sched_features
  echo "LB_BIAS:1" >/sys/kernel/debug/sched_features
  echo "NONTASK_CAPACITY:1" >/sys/kernel/debug/sched_features
  echo "NO_TTWU_QUEUE:1" >/sys/kernel/debug/sched_features
  echo "NO_SIS_AVG_CPU:1" >/sys/kernel/debug/sched_features
  echo "RT_PUSH_IPI:1" >/sys/kernel/debug/sched_features
  echo "NO_FORCE_SD_OVERLAP:1" >/sys/kernel/debug/sched_features
  echo "NO_RT_RUNTIME_SHARE:1" >/sys/kernel/debug/sched_features
  echo "NO_LB_MIN:1" >/sys/kernel/debug/sched_features
  echo "ATTACH_AGE_LOAD:1" >/sys/kernel/debug/sched_features
  echo "ENERGY_AWARE:1" >/sys/kernel/debug/sched_features
  echo "NO_MIN_CAPACITY_CAPPING:1" >/sys/kernel/debug/sched_features
  echo "NO_FBT_STRICT_ORDER:1" >/sys/kernel/debug/sched_features
  echo "EAS_USE_NEED_IDLE:1" >/sys/kernel/debug/sched_features

# governor mode

echo "performance" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor

echo "performance" > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor

echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy7/scaling_governor

#echo "performance" > /sys/class/kgsl/kgsl-3d0/devfreq/governor

#echo "performance" > /sys/class/kgsl/kgsl-3d0/devfreq/governor

# configure bus-dcvs

   # LPDDR5 Tweaks

        #Unlock max drr bus freq
for i in /sys/class/devfreq/soc:qcom,cpu-llcc-ddr-bw ; do
    chmod 666 $i/min_freq
    chmod 666 $i/max_freq
    echo 7980 > $i/min_freq
    echo 7980 > $i/max_freq
    chmod 444 $i/min_freq
    chmod 444 $i/max_freq
done ;

        # Unlock max llcc bw freq
for i in /sys/class/devfreq/soc:qcom,cpu-cpu-llcc-bw ; do
    chmod 666 $i/max_freq
    chmod 666 $i/min_freq
    echo 15258 > $i/min_freq
    echo 15258 > $i/max_freq
    chmod 444 $i/min_freq
    chmod 444 $i/max_freq
done ;
 
		# L3 Cache Tweak

for i in /sys/class/devfreq/18590000.qcom,devfreq-l3:qcom,cpu[0,4,7]-cpu-l3-lat ; do
    chmod 666 $i/min_freq
    chmod 666 $i/max_freq
    echo 1612800000 > $i/min_freq
    echo 1612800000 > $i/max_freq
    chmod 444 $i/min_freq
    chmod 444 $i/max_freq
    echo performance > $i/governor
done ;

        # UFSHC Tweak I guess
for i in /sys/class/devfreq/1d84000.ufshc ; do
    chmod 666 $i/max_freq
    chmod 666 $i/min_freq
    echo 300000000 > $i/min_freq
    echo 300000000 > $i/max_freq
    chmod 444 $i/min_freq
    chmod 444 $i/max_freq
done ;

sleep 1

    # Governor performance
for i in /sys/class/devfreq/soc:qcom,cpu-llcc-ddr-bw ; do
    echo performance > $i/governor
done ;

    # Governor performance 1
for i in /sys/class/devfreq/soc:qcom,cpu-cpu-llcc-bw ; do
    echo performance > $i/governor
done ;

    # Governor performance 2
for i in /sys/class/devfreq/18590000.qcom,devfreq-l3:qcom,cpu[0,4,7]-cpu-l3-lat ; do
    echo performance > $i/governor
done ;

#MemPf
echo 90 > /sys/fs/f2fs/sda28/cp_interval
sleep 0.5
  echo 50 > /sys/fs/f2fs/sda28/gc_urgent_sleep_time
sleep 0.5
  echo 1 > /sys/fs/f2fs/sda28/iostat_enable
sleep 0.5
  echo 134217728 > /sys/block/sda/queue/discard_max_bytes
sleep 2
for i in /sys/devices/platform/soc/1d84000.ufshc ; do
    echo 4000 > $i/auto_hibern8
    echo 0 > $i/clkscale_enable
    echo 0 > $i/clkgate_enable
    echo 1 > $i/max_bus_bw
    echo 0 > $i/rpm_lvl
    echo 0 > $i/spm_lvl
    echo 50 > $i/clkgate_delay_ms_perf
    echo 10 > $i/clkgate_delay_ms_pwr_save
done ;
for i in /sys/class/devfreq/1d84000.ufshc ; do
    chmod 666 $i/min_freq
    echo 300000000 > $i/min_freq
    chmod 444 $i/min_freq
done ;
  
#  Thermal stop to setprop

setprop init.svc.android.thermal-hal stopped
setprop init.svc.vendor.lge-thermal-hal-1-2 stopped
setprop ro.boottime.android.thermal-hal stopped
setprop init.svc.thermal-engine stopped
setprop init.svc_debug_pid.thermal-engine stopped
setprop init.svc_debug_pid.android.thermal-hal stopped

# Disable additional thermal controls
for i in /sys/class/thermal/therm* ; do
    chmod 666 $i/policy
    chmod 666 $i/passive
    chmod 666 $i/mode
    echo user_space > $i/policy
    echo 0 > $i/passive
    echo disabled > $i/mode
    chmod 444 $i/mode
    chmod 444 $i/policy
    chmod 444 $i/passive
done ;

# Disable thermal
for thermal in $(resetprop | awk -F '[][]' '/thermal/ {print $2}'); do
  if [[ $(resetprop "$thermal") == "running" || $(resetprop "$thermal") == "restarting" || $(resetprop "$thermal") == "true" || $(resetprop "$thermal") > "0" ]]; then
    stop "${thermal/init.svc.thermalloadalgod}"
    stop "${thermal/init.svc.vendor-}"
    stop "${thermal/init.svc.vendor.}"
    stop "${thermal/init.thermal_}"
    stop "${thermal/init.svc.}"
    resetprop "$thermal" stopped
  fi
done ;

for i in /sys/class/thermal/*therm ; do
    chmod 666 $i/policy
    chmod 666 $i/passive
    chmod 666 $i/mode
    echo user_space > $i/policy
    echo 0 > $i/passive
    echo disabled > $i/mode
    chmod 444 $i/policy
    chmod 444 $i/passive
    chmod 444 $i/mode
done ;

for i in /sys/class/thermal/cooling_device* ; do
    chmod 666 $i/cur_state
    echo 0 > $i/cur_state
    chmod 444 $i/cur_state
done ;

# battery

echo '5029000' > /sys/class/power_supply/bms/charge_full
echo '100' > /sys/class/power_supply/bms/soh

# fast charging
chmod 777 /sys/class/power_supply/*/*
chmod 777 /sys/module/qpnp_smbcharger/*/*
chmod 777 /sys/module/dwc3_msm/*/*
chmod 777 /sys/module/phy_msm_usb/*/*
setprop persist.vendor.lge.service.qnovo_mode QNOVO_QNI
setprop persist.vendor.lge.actm.mode 22
echo '1' > /sys/kernel/fast_charge/force_fast_charge
echo '1' > /sys/class/power_supply/battery/system_temp_level
echo '1' > /sys/kernel/fast_charge/failsafe
echo '1' > /sys/class/power_supply/battery/allow_hvdcp3
echo '1' > /sys/class/power_supply/usb/pd_allowed
echo '1' > /sys/class/power_supply/battery/subsystem/usb/pd_allowed
echo '0' > /sys/class/power_supply/battery/input_current_limited
echo '1' > /sys/class/power_supply/battery/input_current_settled
echo '0' > /sys/class/qcom-battery/restricted_charging
echo '150' > /sys/class/power_supply/bms/temp_cool
echo '460' > /sys/class/power_supply/bms/temp_hot
echo '460' > /sys/class/power_supply/bms/temp_warm
echo '0' > /sys/class/qcom-battery/restricted_chg
echo '550' > /sys/class/power_supply/battery/charger_temp_max
echo '5000000' > /sys/class/power_supply/usb/current_max
echo '5000000' > /sys/class/power_supply/usb/hw_current_max
echo '5000000' > /sys/class/power_supply/usb/pd_current_max
echo '5000000' > /sys/class/power_supply/usb/ctm_current_max
echo '5000000' > /sys/class/power_supply/usb/sdp_current_max
echo '5000000' > /sys/class/power_supply/main/current_max
echo '5000000' > /sys/class/power_supply/main/constant_charge_current_max
echo '5000000' > /sys/class/power_supply/battery/current_max
echo '5000000' > /sys/class/power_supply/battery/constant_charge_current_max
echo '5600000' > /sys/class/qcom-battery/restricted_current
echo '5000000' > /sys/class/power_supply/pc_port/current_max
echo '5000000' > /sys/class/power_supply/constant_charge_current__max
sleep 1
done ;

# Disable Core control / hotplug

for i in /sys/devices/system/cpu/cpu[0,4,7]/core_ctl ; do
    chmod 666 $i/enable
	echo 0 > $i/enable
	chmod 444 $i/enable
done ;

# Cooking Logs & Cache 
rm -rf /data/resource-cache
rm -rf /data/package_cache
rm -rf /data/dalvik-cache
rm -rf /data/cache
rm -rf /data/vendor/wlan_logs
rm -rf /dev/log/*
rm -rf /sys/kernel/debug/*
rm -rf /data/media/0/DCIM/.thumbnails
rm -rf /data/media/0/Pictures/.thumbnails
rm -rf /data/media/0/Music/.thumbnails
rm -rf /data/media/0/Movies/.thumbnails
rm -rf /data/vendor/thermal/thermal.dump
rm -rf /data/vendor/thermal/last_thermal.dump
rm -rf /data/vendor/thermal/thermal_history.dump
rm -rf /data/vendor/thermal/thermal_history_last.dump
rm -rf /data/anr/*
rm -rf /dev/log/*
echo "0" > /proc/sys/kernel/timer_migration
echo 0 >/sys/fs/selinux/log/deny_unknown
sed -i 's/service logd/service logd disabled/g' /system/etc/init/rc
sed -i 's/on property:sys.log.redirect-stdio=1/on property:sys.log.redirect-stdio=0/g' /system/etc/init/rc
sed -i 's/setprop persist.service.logging.enable 1/# setprop persist.service.logging.enable 1/g' /system/etc/init/rc
sysctl -w kernel.panic=0
sysctl -w vm.panic_on_oom=0
sysctl -w kernel.panic_on_oops=0
sysctl -w kernel.softlockup_panic=0
sysctl -w vm.oom_dump_tasks=0
sysctl -w vm.oom_kill_allocating_task=0
echo "0 0 0 0" > /proc/sys/kernel/printk
echo "off" > /proc/sys/kernel/printk_devkmsg
echo "0" > /proc/sys/debug/exception-trace
echo "0" > /proc/sys/kernel/compat-log

# This code aims to disable the advertising and tracking capabilities of Google Play services.
su -c "pm disable com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdNotificationService"
su -c "pm disable com.google.android.gms/com.google.android.gms.ads.identifier.service.AdvertisingIdService"
#su -c "pm disable com.google.android.gms/com.google.android.gms.nearby.mediums.nearfieldcommunication.NfcAdvertisingService"
#ui_print "✦ Disabled advertising and tracking in Google Play services."
#ui_print " "

# This code aims to restrict Google's data collection and analytics on your Android device.
su -c "pm disable com.google.android.gms/com.google.android.gms.analytics.AnalyticsService"
su -c "pm disable com.google.android.gms/com.google.android.gms.analytics.AnalyticsTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
su -c "pm disable com.google.android.gms/com.google.android.gms.stats.eastworld.EastworldService"
su -c "pm disable com.google.android.gms/com.google.android.gms.stats.service.DropBoxEntryAddedService"
su -c "pm disable com.google.android.gms/com.google.android.gms.stats.PlatformStatsCollectorService"
su -c "pm disable com.google.android.gms/com.google.android.gms.common.stats.GmsCoreStatsService"
su -c "pm disable com.google.android.gms/com.google.android.gms.common.stats.StatsUploadService"
su -c "pm disable com.google.android.gms/com.google.android.gms.backup.stats.BackupStatsService"
su -c "pm disable com.google.android.gms/com.google.android.gms.checkin.CheckinApiService"
su -c "pm disable com.google.android.gms/com.google.android.gms.checkin.CheckinService"
su -c "pm disable com.google.android.gms/com.google.android.gms.tron.CollectionService"
su -c "pm disable com.google.android.gms/com.google.android.gms.common.config.PhenotypeCheckinService"
ui_print "Restricted Google’s data collection on your device."
#ui_print " "
#sleep 1.5

# This code aims to disable HardwareArProviderService that eats your battery 24×7
su -c "pm disable com.google.android.gms/com.google.android.location.internal.server.HardwareArProviderService"
#ui_print "✦ Disabled the battery-draining HardwareArProviderService."
#ui_print " "
#sleep 1.5

# This code aims to disable bug reporting functionality of gms.
su -c "pm disable com.google.android.gms/com.google.android.gms.feedback.FeedbackAsyncService"
su -c "pm disable com.google.android.gms/com.google.android.gms.feedback.LegacyBugReportService"
su -c "pm disable com.google.android.gms/com.google.android.gms.feedback.OfflineReportSendTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.googlehelp.metrics.ReportBatchedMetricsGcmTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
su -c "pm disable com.google.android.gms/com.google.android.gms.locationsharingreporter.service.reporting.periodic.PeriodicReporterMonitoringService"
su -c "pm disable com.google.android.gms/com.google.android.location.reporting.service.ReportingAndroidService"
su -c "pm disable com.google.android.gms/com.google.android.location.reporting.service.ReportingSyncService"
su -c "pm disable com.google.android.gms/com.google.android.gms.common.stats.net.NetworkReportService"
su -c "pm disable com.google.android.gms/com.google.android.gms.presencemanager.service.PresenceManagerPresenceReportService"
su -c "pm disable com.google.android.gms/com.google.android.gms.usagereporting.service.UsageReportingIntentService"
#ui_print "✦ Disabled bug reporting in Google Play services."
#ui_print " "
#sleep 1.5

# This code aims to disable Google Cast services.
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService_Isolated"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.media.CastMediaRoute2ProviderService_Persistent"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService_Isolated"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.media.CastMediaRouteProviderService_Persistent"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService_Isolated"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.media.CastRemoteDisplayProviderService_Persistent"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.service.CastPersistentService_Persistent"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService_Isolated"
su -c "pm disable com.google.android.gms/com.google.android.gms.cast.service.CastSocketMultiplexerLifeCycleService_Persistent"
su -c "pm disable com.google.android.gms/com.google.android.gms.chimera.CastPersistentBoundBrokerService"
#ui_print "✦ Disabled Google Cast services."
#ui_print " "
#sleep 1.5

# This code aims to disable debugging services related to Google Play Services.
#su -c "pm disable com.google.android.gms/com.google.android.gms.nearby.messages.debug.DebugPokeService"
su -c "pm disable com.google.android.gms/com.google.android.gms.clearcut.debug.ClearcutDebugDumpService"
#ui_print "✦ Disabled debugging services in Google Play Services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to component discovery within Google Play Services and Firebase.
su -c "pm disable com.google.firebase.components.ComponentDiscoveryService"
#su -c "pm disable com.google.android.gms/com.google.android.gms.nearby.discovery.service.DiscoveryService"
#su -c "pm disable com.google.android.gms/com.google.mlkit.common.internal.MlKitComponentDiscoveryService"
#ui_print "✦ Disabled component discovery services in Google Play and Firebase."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to location and time zone information.
su -c "pm disable com.google.android.gms/com.google.android.gms.geotimezone.GeoTimeZoneService"
su -c "pm disable com.google.android.gms/com.google.android.gms.location.geocode.GeocodeService"
#ui_print "✦ Disabled location and time zone services."
#ui_print " "
#sleep 1.5

# This code aims to enable specific services related to Google Play Services, particularly those associated with authentication and account management.
su -c "pm enable com.google.android.gms/com.google.android.gms.chimera.GmsIntentOperationService_AuthAccountIsolated com.google.android.gms/com.google.android.gms.chimera.GmsIntentOperationService_AuthAccountIsolate"
su -c "pm enable com.google.android.gms/com.google.android.gms.chimera.PersistentApiService_AuthAccountIsolated"
su -c "pm enable com.google.android.gms/com.google.android.gms.chimera.PersistentIntentOperationService_AuthAccountIsolated"
#ui_print "✦ Disabled key authentication services in Google Play."
#ui_print " "
#sleep 1.5

# This code aims to disable various background update services.
su -c "pm disable com.google.android.gms/com.google.android.gms.auth.folsom.service.FolsomPublicKeyUpdateService"
su -c "pm disable com.google.android.gms/com.google.android.gms.fonts.update.UpdateSchedulerService"
su -c "pm disable com.google.android.gms/com.google.android.gms.icing.proxy.IcingInternalCorporaUpdateService"
su -c "pm disable com.google.android.gms/com.google.android.gms.instantapps.routing.DomainFilterUpdateService"
su -c "pm disable com.google.android.gms/com.google.android.gms.mobiledataplan.service.PeriodicUpdaterService"
su -c "pm disable com.google.android.gms/com.google.android.gms.phenotype.service.sync.PackageUpdateTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.update.SystemUpdateGcmTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.update.SystemUpdateService"
su -c "pm disable com.google.android.gms/com.google.android.gms.update.UpdateFromSdCardService"
#ui_print "✦ Disabled various background update services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to smartwatches and wearables.
su -c "pm disable com.google.android.gms/com.google.android.gms.backup.wear.BackupSettingsListenerService"
su -c "pm disable com.google.android.gms/com.google.android.gms.dck.service.DckWearableListenerService"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncAccountService"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncConfigService"
#su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncConnectionService"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.wearable.WearableSyncMessageService"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.wearables.WearableSyncService"
#su -c "pm disable com.google.android.gms/com.google.android.gms.wearable.service.WearableControlService"
su -c "pm disable com.google.android.gms/com.google.android.gms.wearable.service.WearableService"
#su -c "pm disable com.google.android.gms/com.google.android.gms.nearby.fastpair.service.WearableDataListenerService"
su -c "pm disable com.google.android.gms/com.google.android.location.wearable.WearableLocationService"
su -c "pm disable com.google.android.gms/com.google.android.location.fused.wearable.GmsWearableListenerService"
su -c "pm disable com.google.android.gms/com.google.android.gms.mdm.services.MdmPhoneWearableListenerService"
su -c "pm disable com.google.android.gms/com.google.android.gms.tapandpay.wear.WearProxyService"
#ui_print "✦ Disabled services for smartwatches and wearables."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to Trusted Agents / Find My Device
#su -c "pm disable com.google.android.gms/com.google.android.gms.auth.trustagent.GoogleTrustAgent"
#su -c "pm disable com.google.android.gms/com.google.android.gms.trustagent.api.bridge.TrustAgentBridgeService"
#su -c "pm disable com.google.android.gms/com.google.android.gms.trustagent.api.state.TrustAgentState"
#ui_print "✦ Disabled Trusted Agents / Find My Device services." 
#ui_print " "
#sleep 1.5

# This code aims to disable services related to enpromo"
su -c "pm disable com.google.android.gms/com.google.android.gms.enpromo.PromoInternalPersistentService"
su -c "pm disable com.google.android.gms/com.google.android.gms.enpromo.PromoInternalService"
#ui_print "✦ Disabled enpromo-related services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to emergency features and potentially child safety settings. 
su -c "pm disable com.google.android.gms/com.google.android.gms.thunderbird.EmergencyLocationService" 
su -c "pm disable com.google.android.gms/com.google.android.gms.thunderbird.EmergencyPersistentService"
su -c "pm disable com.google.android.gms/com.google.android.gms.kids.chimera.KidsServiceProxy"
su -c "pm disable com.google.android.gms/com.google.android.gms.personalsafety.service.PersonalSafetyService"
#ui_print "✦ Disabled emergency features and child safety services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to Google Fit health and fitness tracking app.
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.cache.DataUpdateListenerCacheService"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.ble.FitBleBroker"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.config.FitConfigBroker"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.goals.FitGoalsBroker"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.history.FitHistoryBroker"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.internal.FitInternalBroker"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.proxy.FitProxyBroker"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.recording.FitRecordingBroker"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.sensors.FitSensorsBroker"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.service.sessions.FitSessionsBroker"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.sensors.sample.CollectSensorService"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.sync.FitnessSyncAdapterService" 
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.sync.SyncGcmTaskService"
#ui_print "✦ Disabled Google Fit health tracking services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to Google Nearby
#su -c "pm disable com.google.android.gms/com.google.android.gms.nearby.bootstrap.service.NearbyBootstrapService"
#su -c "pm disable com.google.android.gms/com.google.android.gms.nearby.connection.service.NearbyConnectionsAndroidService"
#su -c "pm disable com.google.android.gms/com.google.location.nearby.direct.service.NearbyDirectService"
#su -c "pm disable com.google.android.gms/com.google.android.gms.nearby.messages.service.NearbyMessagesService"
##ui_print "✦ Disabled Google Nearby services."
##ui_print " "
##sleep 1.5

# This code aims to disable services related to logging and data collection.
su -c "pm disable com.google.android.gms/com.google.android.gms.analytics.internal.PlayLogReportingService"
su -c "pm disable com.google.android.gms/com.google.android.gms.romanesco.ContactsLoggerUploadService"
su -c "pm disable com.google.android.gms/com.google.android.gms.magictether.logging.DailyMetricsLoggerService"
su -c "pm disable com.google.android.gms/com.google.android.gms.checkin.EventLogService"
su -c "pm disable com.google.android.gms/com.google.android.gms.backup.component.FullBackupJobLoggerService"
#ui_print "✦ Disabled logging and data collection services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to security, app verification, and potentially network management.
su -c "pm disable com.google.android.gms/com.google.android.gms.security.safebrowsing.SafeBrowsingUpdateTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.security.verifier.ApkUploadService"
su -c "pm disable com.google.android.gms/com.google.android.gms.security.verifier.InternalApkUploadService"
su -c "pm disable com.google.android.gms/com.google.android.gms.security.snet.SnetIdleTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.security.snet.SnetNormalTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.security.snet.SnetService"
su -c "pm disable com.google.android.gms/com.google.android.gms.tapandpay.security.StorageKeyCacheService"
su -c "pm disable com.google.android.gms/com.google.android.gms.droidguard.DroidGuardGcmTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.pay.security.storagekey.service.StorageKeyCacheService"
#ui_print "✦ Disabled security and app verification services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to Google Pay (formerly Android Pay) & Google Wallet.
su -c "pm disable com.google.android.gms/com.google.android.gms.tapandpay.gcmtask.TapAndPayGcmTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.tapandpay.globalactions.QuickAccessWalletService"
su -c "pm disable com.google.android.gms/com.google.android.gms.tapandpay.globalactions.WalletQuickAccessWalletService"
su -c "pm disable com.google.android.gms/com.google.android.gms.pay.gcmtask.PayGcmTaskService"
su -c "pm disable com.google.android.gms/com.google.android.gms.pay.hce.service.PayHceService"
su -c "pm disable com.google.android.gms/com.google.android.gms.pay.notifications.PayNotificationService"
su -c "pm disable com.google.android.gms/com.google.android.gms.wallet.service.PaymentService"
su -c "pm disable com.google.android.gms/com.google.android.gms.wallet.service.WalletGcmTaskService"
#ui_print "✦ Disabled Google Pay and Wallet services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to location.
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.cache.DataUpdateListenerCacheService"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.sensors.sample.CollectSensorService"
su -c "pm disable com.google.android.gms/com.google.android.gms.fitness.sync.SyncGcmTaskService"
su -c "pm disable com.google.android.gms/com.google.android.location.fused.FusedLocationService"
#su -c "pm enable com.google.android.gms/com.google.android.location.internal.server.GoogleLocationService"
su -c "pm disable com.google.android.gms/com.google.android.location.network.NetworkLocationService"
su -c "pm disable com.google.android.gms/com.google.android.location.persistent.LocationPersistentService"
su -c "pm disable com.google.android.gms/com.google.android.location.reporting.service.LocationHistoryInjectorService"
su -c "pm disable com.google.android.gms/com.google.android.location.util.LocationAccuracyInjectorService"
su -c "pm disable com.google.android.gms/com.google.android.location.wearable.WearableLocationService"
su -c "pm disable com.google.android.gms/com.google.android.gms.locationsharing.service.LocationSharingSettingInjectorService"
su -c "pm disable com.google.android.gms/com.google.android.gms.locationsharing.service.LocationSharingService"
su -c "pm disable com.google.android.gms/com.google.android.gms.semanticlocation.service.SemanticLocationService"
#ui_print "✦ Disabled location services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to components within Google Play Services related to Google Play Games.
su -c "pm disable com.google.android.gms/com.google.android.gms.games.chimera.GamesSignInIntentServiceProxy"
su -c "pm disable com.google.android.gms/com.google.android.gms.games.chimera.GamesSyncServiceNotificationProxy"
su -c "pm disable com.google.android.gms/com.google.android.gms.games.chimera.GamesUploadServiceProxy"
su -c "pm disable com.google.android.gms/com.google.android.gms.gp.gameservice.GameService"
su -c "pm disable com.google.android.gms/com.google.android.gms.gp.gameservice.GameSessionService"
#ui_print "✦ Disabled Google Play Games-related services."
#ui_print " "
#sleep 1.5

# This code aims to disable services related to Google Instant Apps.
su -c "pm disable com.google.android.gms/com.google.android.gms.chimera.GmsApiServiceNoInstantApps"
su -c "pm disable com.google.android.gms/com.google.android.gms.chimera.PersistentApiServiceNoInstantApps"
su -c "pm disable com.google.android.gms/com.google.android.gms.instantapps.service.InstantAppsService"
su -c "pm disable com.google.android.gms/com.google.android.gms.chimera.UiApiServiceNoInstantApps"

#ui_print "✦ Disabled Google Instant Apps services."
#ui_print " "
exit 0