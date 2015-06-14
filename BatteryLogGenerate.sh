#!/bin/sh
# This script simply prints the battery states in equal interval of time.
# Usefull for battery monitoring purposes

timeinterval=10
BatteryPATH='/sys/bus/acpi/drivers/battery/PNP0C0A:00/power_supply/BAT0/'

while :
do
    echo -n $(date +%s)" "
    echo -n $(cat "$BatteryPATH"/energy_now)" "
    echo $(cat "$BatteryPATH"/capacity)
    sleep $timeinterval
done
