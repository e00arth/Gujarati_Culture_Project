#!/bin/bash
export ANDROID_HOME=/home/patel/Android/Sdk

echo "Waiting for GUI emulator to boot..."
$ANDROID_HOME/platform-tools/adb wait-for-device
while [ "$($ANDROID_HOME/platform-tools/adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
    sleep 2
done
echo "Emulator booted! Launching app..."
$ANDROID_HOME/platform-tools/adb shell am start -n com.gujarati.culture/.MainActivity
echo "Done!"
