#!/bin/bash
cd /home/patel/AI/Gujarat/Gujarati_Culture_Project/App1_Lok_Sahitya_Kehavat/Android_Sample
export ANDROID_HOME=/home/patel/Android/Sdk

echo "Starting build process..."
./gradlew assembleDebug

echo "Waiting for emulator to fully boot..."
$ANDROID_HOME/platform-tools/adb wait-for-device
while [ "$($ANDROID_HOME/platform-tools/adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
    sleep 2
done
echo "Emulator booted!"

echo "Installing application..."
$ANDROID_HOME/platform-tools/adb install -r app/build/outputs/apk/debug/app-debug.apk

echo "Launching application..."
$ANDROID_HOME/platform-tools/adb shell am start -n com.gujarati.culture/.MainActivity
echo "Done!"
