#!/usr/bin/env bash
set -e

# Setup environment variables
export JAVA_HOME="/home/patel/development/jdk-21"
export ANDROID_HOME="/home/patel/Android/Sdk"
export ANDROID_AVD_HOME="/home/patel/.android/avd"
export CHROME_EXECUTABLE="/usr/bin/chromium-browser"
export PATH="$JAVA_HOME/bin:/home/patel/development/flutter/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

echo "=========================================================="
echo " Starting Gujarat Ni Asmita: Heritage Hub (Flutter App)   "
echo "=========================================================="

# Check if an android device or emulator is already connected
DEVICE_ID=$(adb devices 2>/dev/null | grep -v "List of devices" | grep "device$" | head -n1 | awk '{print $1}' || true)

if [ -z "$DEVICE_ID" ]; then
    echo "Starting Android Emulator 'pixel'..."
    nohup "$ANDROID_HOME/emulator/emulator" -avd pixel -gpu host > /tmp/emulator.log 2>&1 &
    
    echo "Waiting for emulator to boot..."
    adb wait-for-device
    while [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]; do
        sleep 1
    done
    echo "Emulator booted successfully!"
fi

cd "$(dirname "$0")/../app"

echo "Launching Flutter App..."
flutter run
