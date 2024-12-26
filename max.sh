#!/system/bin/sh
# This script will be executed in late_start service mode
# "New Era of Programming Strategies"
# Author: Leudyart@  © 2024
# ×××××××××××××××××××××××××× #
MODDIR=${0%/*} # get parent directory

sleep 10
# Variables
UCLAMP_PATH="/dev/stune/top-app/uclamp.max"
CPUSET_PATH="/dev/cpuset"
MODULE_PATH="/sys/module"
KERNEL_PATH="/proc/sys/kernel"
IPV4_PATH="/proc/sys/net/ipv4"
MEMORY_PATH="/proc/sys/vm"
MGLRU_PATH="/sys/kernel/mm/lru_gen"
SCHEDUTIL2_PATH="/sys/devices/system/cpu/cpufreq/schedutil"
SCHEDUTIL_PATH="/sys/devices/system/cpu/cpu0/cpufreq/schedutil"

#--------------------------------------------
# SET WINDOW ANIMATION SCALE TO 0.0X
#su -c "settings put global window_animation_scale 0.1"

# SET TRANSITION ANIMATION SCALE TO 0.0X
#su -c "settings put global transition_animation_scale 0.1"

# SET ENTERTAINER DURATION SCALE TO 0.2X
#su -c "settings put global animator_duration_scale 0.3"

#--------------------------------------------

# GRANT LOCATION ACCESS PERMISSIONS TO THE GOOGLE PLAY SERVICES APP
pm grant com.google.android.gms android.permission.ACCESS_COARSE_LOCATION
pm grant com.google.android.gms android.permission.ACCESS_FINE_LOCATION

#--------------------------------------------

# STOP SERVICES WITHOUT SUPERUSER PRIVILEGES
stop logd
stop traced
stop tcpdump
stop cnss_diag
stop idd-logreader
stop idd-logreadermain

         # ENABLE BUS-DCVS FOR LPDDR4X
		# DDR (LPDDR4X) memory type detection
        ddr_type=`od -An -tx /proc/device-tree/memory/ddr_device_type`
        ddr_type4="07"  # LPDDR4X

        # Iterate over the devices on the platform
        for device in /sys/devices/platform/soc
do
        # Bandwidth controller (bus-dcvs) for LPDDR4X  
        for cpubw in $device/*cpu-cpu-ddr-bw/devfreq/*cpu-cpu-ddr-bw
do
        if [ ${ddr_type:4:2} == $ddr_type4 ]; then
		# Apply optimized settings for LPDDR4X
            echo "bw_hwmon" > $cpubw/governor
            echo 10 > $cpubw/polling_interval
            echo 400 > $cpubw/min_freq
            
            # Fine-tuned bandwidth zones for LPDDR4X
            echo "2200 3300 4200 5100 6200 7500 10000 12000 13800" > $cpubw/bw_hwmon/mbps_zones
            echo 60 > $cpubw/bw_hwmon/io_percent
            echo 3 > $cpubw/bw_hwmon/sample_ms
            echo 80 > $cpubw/bw_hwmon/decay_rate
            echo 50 > $cpubw/bw_hwmon/bw_step
            echo 10 > $cpubw/bw_hwmon/hist_memory
            echo 20 > $cpubw/bw_hwmon/down_thres
            echo 0 > $cpubw/bw_hwmon/guard_band_mbps
            echo 350 > $cpubw/bw_hwmon/up_scale
            echo 1000 > $cpubw/bw_hwmon/idle_mbps
        fi
    done
            # Call the function to apply settings
apply_sched_schedutil_dcvs

            # Memory Latency Controller
            for memlat in $device/*cpu*-lat/devfreq/*cpu*-lat
do
            echo "mem_latency" > $memlat/governor
            echo 10 > $memlat/polling_interval
            echo 150 > $memlat/mem_latency/ratio_ceil
    done

            # Floor Latency Controller (latfloor)
            for latfloor in $device/*cpu*-ddr-latfloor*/devfreq/*cpu-ddr-latfloor*
do
            echo "compute" > $latfloor/governor
            echo 10 > $latfloor/polling_interval
    done
done

# DISABLE THERMAL BCL HOTPLUG TO SWITCH GOVERNOR
echo 0 > /sys/module/msm_thermal/core_control/enabled
echo 0 > /sys/module/msm_thermal/parameters/enabled
echo 0 > /sys/module/msm_thermal/vdd_restriction/enabled

# GPU TWEAKS ADRENO ( BALANCE BETWEEN PERFORMANCE AND ENERGY EFFICIENCY )
# Desactivar el throttling para evitar limitar el rendimiento cuando no sea necesario
echo 0 > /sys/class/kgsl/kgsl-3d0/throttling
# No forzar siempre el reloj activo, para permitir que el gobernador ajuste dinámicamente
echo 0 > /sys/class/kgsl/kgsl-3d0/force_clk_on
# Mantener el bus unificado para una gestión eficiente de la energía
echo 0 > /sys/class/kgsl/kgsl-3d0/bus_split
# Activar AdrenoBoost para mejorar la respuesta cuando la carga aumenta
echo 1 > /sys/class/kgsl/kgsl-3d0/devfreq/adrenoboost
# Permitir que el bus se gestione dinámicamente, no siempre activo
echo 0 > /sys/class/kgsl/kgsl-3d0/force_bus_on
# Mantener el estado de pwrnap para ahorrar energía cuando sea posible
echo 1 > /sys/class/kgsl/kgsl-3d0/pwrnap
# Activar popp para gestionar la energía eficientemente sin sacrificar rendimiento
echo 1 > /sys/class/kgsl/kgsl-3d0/popp
# No forzar los rieles siempre activos para que el sistema pueda administrar la energía de manera más eficiente
echo 0 > /sys/class/kgsl/kgsl-3d0/force_rail_on
# No forzar la desactivación del "nap", permitiendo que el sistema entre en modo bajo consumo cuando no hay actividad
echo 0 > /sys/class/kgsl/kgsl-3d0/force_no_nap
# Lower the threshold so that it will overclock with only 10-30% load:
echo 10 > /sys/class/kgsl/kgsl-3d0/idle_timer
# Keep the drop threshold at 10-15%
#echo 3 > /sys/class/kgsl/kgsl-3d0/pwrlevel_change
# Use a moderate interval, such as 35 ms, for a good balance.
echo 20 > /sys/class/kgsl/kgsl-3d0/devfreq/polling_interval
# Reduce timeout to 40ms
echo 30 > /sys/class/kgsl/kgsl-3d0/idle_timeout
# Increase the temperature threshold to 65°C if you don't have overheating problems
echo 70 > /sys/class/kgsl/kgsl-3d0/throttle_temp

# ADJUST THE VIRTUAL MEMORY NEW BALANCED
echo 20 > /proc/sys/vm/stat_interval
echo 20 > /proc/sys/vm/dirty_ratio
echo 10 > /proc/sys/vm/dirty_background_ratio
echo 500 > /proc/sys/vm/extfrag_threshold
echo 50 > /proc/sys/vm/overcommit_ratio
echo 75 > /proc/sys/vm/vfs_cache_pressure
echo 2000 > /proc/sys/vm/dirty_expire_centisecs
echo 1000 > /proc/sys/vm/dirty_writeback_centisecs

# Adjust zRAM parameters (if available)
if [ -d /sys/block/zram0 ]; then
  # Set zRAM size to 2GB
  echo 2147483648 > /sys/block/zram0/disksize
  
  # Set compression algorithm to lz4
  echo lz4 > /sys/block/zram0/comp_algorithm
  
  # Set swappiness to 50 for a balance between RAM and zRAM
  echo 50 > /proc/sys/vm/swappiness
  
  # Initialize zRAM
  /sbin/blkdiscard /dev/block/zram0
  mkswap /dev/block/zram0
  swapon /dev/block/zram0
fi

# The default value is usually 64, meaning the kernel wakes up processes as soon as 64 units of entropy are available.Random entropy settings
echo 64 > /proc/sys/kernel/random/read_wakeup_threshold
echo 64 > /proc/sys/kernel/random/write_wakeup_threshold

## The SCHEDUTIL GOVERNOR dynamically adjusts the CPU frequency based on the current workload, offering a balance between performance and power efficiency. This setup ensures that your processor efficiently manages workloads across all cores.##
# SET 'SCHEDUTIL' GOVERNOR FOR LITTLE CORES (CPU0 TO CPU3)
echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
# SET 'SCHEDUTIL' GOVERNOR FOR BIG CORES (CPU4 TO CPU7)
echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
echo "schedutil" > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor

# OPTIMIZED CONFIGURATION FOR "BIG" CORES (HIGH PERFORMANCE)for CPU governor schedutil
# Reduce response time for rapid ramp-up
echo 300 > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/up_rate_limit_us
# Reduces the time to lower the frequency, improving energy efficiency
echo 7000 > /sys/devices/system/cpu/cpu4/cpufreq/schedutil/down_rate_limit_us
# OPTIMIZED CONFIGURATION FOR "LITTLE" CORES (LOW CONSUMPTION)
# Slightly more conservative setting for less aggressive frequency boost
echo 500 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/up_rate_limit_us
# Reduced slightly to balance efficiency and response
echo 4000 > /sys/devices/system/cpu/cpu0/cpufreq/schedutil/down_rate_limit_us

# ENABLE THE "I/O WAIT BOOST" FEATURE FOR SPECIFIC CPU FREQUENCY SCALING POLICIES (POLICY0 AND POLICY4) WHEN USING THE SCHEDUTIL GOVERNOR.
echo 1 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/iowait_boost_enable
echo 1 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/iowait_boost_enable

# CPUSET SETTINGS - OPTIMIZED FOR BIG.LITTLE ARCHITECTURE
# Maximiza el rendimiento para las aplicaciones en primer plano
echo 0-7 > /dev/cpuset/top-app/cpus

# BALANCEA TAREAS VISIBLES EN SEGUNDO PLANO CON UN USO EFICIENTE DE NÚCLEOS
echo 0-3,5-6 > /dev/cpuset/foreground/cpus

# OPTIMIZA EL CONSUMO ENERGÉTICO PARA TAREAS DE FONDO DE BAJA PRIORIDAD
echo 0-2 > /dev/cpuset/background/cpus

# PRIORIZACIÓN PARA TAREAS CRÍTICAS DEL SISTEMA EN SEGUNDO PLANO
echo 0-2,6 > /dev/cpuset/system-background/cpus

# AHORRO ENERGÉTICO PARA TAREAS ALTAMENTE RESTRINGIDAS
echo 0-1 > /dev/cpuset/restricted/cpus

# KERNEL PANIC OFF
echo 0 > /proc/sys/kernel/panic
echo 0 > /proc/sys/kernel/panic_on_oops
echo 0 > /proc/sys/kernel/panic_on_warn
echo 0 > /sys/module/kernel/parameters/panic
echo 0 > /sys/module/kernel/parameters/panic_on_warn
echo 0 > /sys/module/kernel/parameters/pause_on_oops
echo 0 > /proc/sys/kernel/softlockup_panic
echo 0 > /proc/sys/kernel/nmi_watchdog

# SET IO SCHEDULER TWEAKS
echo 0 > /sys/block/sda/queue/add_random
echo 0 > /sys/block/sda/queue/rotational
echo 0 > /sys/block/sda/queue/rq_affinity
echo 0 > /sys/block/sda/queue/nomerges

# READ-AHEAD SIZE ADJUSTMENTS TO IMPROVE PERFORMANCE
echo 256 > /sys/block/sda/queue/read_ahead_kb
echo 256 > /sys/block/sdarpmb/queue/read_ahead_kb
echo 256 > /sys/block/loop0/queue/read_ahead_kb

# MAXIMUM NUMBER OF REQUESTS IN QUEUE SETTINGS
echo 128 > /sys/block/mmcblk0/queue/nr_requests
echo 128 > /sys/block/mmcblk1/queue/nr_requests

# MQ-DEADLINE I/O SCHEDULER 
echo mq-deadline > /sys/block/sda/queue/scheduler

# SELECT MQ-DEADLINE AS THE ACTIVE I/O SCHEDULER
echo mq-deadline > /sys/block/sda/queue/scheduler
# Asynchronous depth (adjusted for UFS 4.0)
echo 12 > /sys/block/sda/queue/iosched/async_depth
# FIFO batch size (for sequential operations)
echo 32 > /sys/block/sda/queue/iosched/fifo_batch
# Enable request merges at the front of the queue
echo 1 > /sys/block/sda/queue/iosched/front_merges
# Priority aging expiration (adjusted for better latency)
echo 3000 > /sys/block/sda/queue/iosched/prio_aging_expire
# Maximum wait time for read requests
echo 100 > /sys/block/sda/queue/iosched/read_expire
# Maximum wait time for write requests
echo 2000 > /sys/block/sda/queue/iosched/write_expire
# Number of writes allowed before prioritizing reads
echo 1 > /sys/block/sda/queue/iosched/writes_starved

# THESE CONFIGURATIONS ARE DESIGNED TO IMPROVE SYSTEM RESPONSIVENESS ON MOBILE DEVICES WHILE OPTIMIZING POWER CONSUMPTION, ESPECIALLY IN BIG.LITTLE CORE CONFIGURATIONS. PARAMETERS SUCH AS NEXT_BUDDY, TTWU_QUEUE, AND SCHED_MIGRATION_COST_NS ENHANCE RESPONSIVENESS, WHILE CONFIGURATIONS LIKE ENERGY_AWARE AND ARCH_POWER BALANCE PERFORMANCE AND ENERGY EFFICIENCY.
#echo "NEXT_BUDDY" > /sys/kernel/debug/sched_features
echo "ARCH_POWER" > /sys/kernel/debug/sched_features
echo "UTIL_EST" > /sys/kernel/debug/sched_features
echo "ENERGY_AWARE" > /sys/kernel/debug/sched_features
echo "NO_DOUBLE_TICK" > /sys/kernel/debug/sched_features
#echo "TTWU_QUEUE" > /sys/kernel/debug/sched_features

# SCHEDULER ADJUSTMENTS. SPECIFICALLY, THEY TWEAK HOW THE CPU SCHEDULER MANAGES TASK SWITCHING, LATENCY, TASK MIGRATION, AND OVERHEAD. THESE PARAMETERS HELP OPTIMIZE HOW TASKS ARE DISTRIBUTED ACROSS CPU CORES, BALANCING SYSTEM RESPONSIVENESS, PERFORMANCE, AND POWER EFFICIENCY.
# A LOWER VALUE ALLOWS TASKS TO SWITCH FASTER, IMPROVING SYSTEM RESPONSIVENESS.
echo 25000 > /proc/sys/kernel/sched_min_granularity_ns
# REDUCES LATENCY, MAKING TASKS RESPOND MORE QUICKLY.
echo 2500000 > /proc/sys/kernel/sched_latency_ns
# LOWER MIGRATION COST ALLOWS CPU SWITCHING TO HAPPEN MORE EFFICIENTLY AND QUICKLY.
echo 15000 > /proc/sys/kernel/sched_migration_cost_ns
# FEWER TASKS MIGRATING SIMULTANEOUSLY CAN REDUCE OVERHEAD.
echo 10 > /proc/sys/kernel/sched_nr_migrate
# DECREASE WAKEUP GRANULARITY TO IMPROVE TASK RESPONSE TIME.
echo 750000 > /proc/sys/kernel/sched_wakeup_granularity_ns

# --- ALWAYS ALLOW SCHED BOOSTING ON TOP-APP TASKS ---
echo 0 > /proc/sys/kernel/sched_min_task_util_for_colocation

# --- GROUPING TASKS TWEAK ---
echo 0 > /proc/sys/kernel/sched_autogroup_enabled

# --- ENABLE CRF BY DEFAULT ---
echo 1 > /proc/sys/kernel/sched_child_runs_first
fi

# OVERALL, THESE TCP TWEAKS AIM TO REDUCE LATENCY AND IMPROVE RESPONSIVENESS FOR NETWORK COMMUNICATIONS. THEY ARE PARTICULARLY USEFUL FOR APPLICATIONS THAT PRIORITIZE REAL-TIME INTERACTION OR DATA STREAMING.
# --- TCP ---
# Disable TCP timestamps
echo 0 > /proc/sys/net/ipv4/tcp_timestamps
# Enable TCP low latency mode
echo 1 > /proc/sys/net/ipv4/tcp_low_latency

# DISABLE PERIODIC KCOMPACTD WAKEUPS. WE DO NOT USE THP, SO HAVING MANY
# HUGE PAGES IS NOT AS NECESSARY.
echo 0 > /proc/sys/vm/compaction_proactiveness

# Wait for 10 seconds after the system starts
sleep 10

# RUN FSTRIM ON SPECIFIED DIRECTORIES
fstrim -v /cache
fstrim -v /system
fstrim -v /vendor
fstrim -v /data
fstrim -v /preload

sleep 1
# Sync before execute to avoid crashes
sync


