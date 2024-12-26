# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false
AUTOMOUNT=true

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=true

# Set to true if you need late_start service script
LATESTARTSERVICE=true
#################################################

REPLACE="
/system/etc/gps.conf
/system/vendor/etc/gps.conf
"

NEW_GPS_CONF="/path/to/new/gps.conf"

for file in $REPLACE; do
    if [ -f "$file" ]; then
        echo "Replacing $file with $NEW_GPS_CONF"
    else
        echo "File not found: $file. Placing new file."
    fi
    cp "$NEW_GPS_CONF" "$file"
    chmod 644 "$file"
done
#################################################
SKIPUNZIP=1
RM_RF() {
rm /sdcard/Documents/max/max.log 2>/dev/null
rm /sdcard/max.log 2>/dev/null
rm /sdcard/max/max.txt 2>/dev/null
rm $MODPATH/LICENSE 2>/dev/null
rm $MODPATH/README.md 2>/dev/null
}
SET_PERMISSION() {
ui_print "- Setting Permissions"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive $MODPATH/max.sh 0 0 0755 0700
}
MOD_EXTRACT() {
ui_print "- Extracting Module Files"
unzip -o "$ZIPFILE" max.sh -d $MODPATH >&2
unzip -o "$ZIPFILE" service.sh -d $MODPATH >&2
unzip -o "$ZIPFILE" module.prop -d $MODPATH >&2
unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2
}
MOD_PRINT() {
ui_print "- MAX"
ui_print "- Installing"
}
set -x
RM_RF
MOD_PRINT
MOD_EXTRACT
SET_PERMISSION


