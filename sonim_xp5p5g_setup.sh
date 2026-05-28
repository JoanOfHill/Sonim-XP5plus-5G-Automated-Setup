#!/bin/bash
# Quick and dirty Sonim XP5plus 5G setup script
# @JoanOfHill

# APK package names and locations
apk_list=(
	"io.github.sspanak.tt9|https://github.com/sspanak/tt9/releases/download/v61.0/tt9-v61.0.apk"
	"com.loudtalks|https://zello.com/data/android/latest/zello-sonim.apk"
	"org.fdroid.fdroid|https://f-droid.org/F-Droid.apk"
	"com.aurora.store|https://f-droid.org/repo/com.aurora.store_73.apk"
	"at.bitfire.davdroid|https://f-droid.org/repo/at.bitfire.davdroid_405100003.apk"
	"se.lublin.mumla|https://f-droid.org/repo/se.lublin.mumla_3070300.apk"
	"eu.siacs.conversations|https://f-droid.org/repo/eu.siacs.conversations_4217304.apk"
	"com.yubico.yubioath|https://f-droid.org/repo/com.yubico.yubioath_703052.apk"
	"org.thoughtcrime.securesms|https://github.com/tw-hx/Signal-Android/releases/download/v8.7.3.0-FOSS/Signal-Android-website-foss-prod-universal-release-signed-8.7.3.apk"
	"de.markusfisch.android.binaryeye|https://f-droid.org/repo/de.markusfisch.android.binaryeye_168.apk"
	"org.woheller69.gpscockpit|https://f-droid.org/repo/org.woheller69.gpscockpit_290.apk"
)

# Error storage array
failed_steps=()

log_failure() {
	echo "Error: $1"
	failed_steps+=("$1")
}

# APK downloader and installer
fetch_and_install(){
	local pkg_name="$1"
	local url="$2"
	local filename=$(basename "$url")
	local tmp_dir="$HOME/tmp/sonim"

	echo "Processing $filename..."

	if [ ! -d "$tmp_dir" ]; then
		mkdir -p "$tmp_dir"
	fi

	if [ ! -f "$tmp_dir/$filename" ]; then
		if ! wget -q "$url" -O "$tmp_dir/$filename"; then
			log_failure "Download failed for $filename"
			return 1
		fi
	else
		echo "Using cached $filename..."
	fi

	if ! adb install -r "$tmp_dir/$filename" >/dev/null 2>&1; then
		log_failure "Install command failed for $filename"
		return 1
	fi
	
	if ! adb shell pm list packages "$pkg_name" | grep -q "$pkg_name"; then
		log_failure "Install verification failed for $pkg_name"
		return 1
	fi
	
	echo "Successfully installed and verified $filename"
}

# Verify ADB settings
verify_setting() {
	local namespace="$1"
	local key="$2"
	local expected="$3"
	local description="$4"
	
	local result=$(adb shell settings get "$namespace" "$key" | tr -d '\r')

	if [ "$result" != "$expected" ]; then
		log_failure "$description (Expected: $expected, Got: $result)"
	else
		echo "$description"
	fi
}

echo "Sonim XP5plus 5G Autoconfiguration Script"
echo
echo "DEVELOPER MODE SETUP INSTRUCTIONS"
echo "1. From the main screen, press the *#*#0701#*#* keys and click the \"OPEN DIAG PROPERTY\" button"
echo "2. Navigate to System Settings -> About phone -> Build number and click the entry 7 times"
echo "3. Press the back button and select System -> Developer options and ensure that \"Use developer options\" is toggled ON"
echo "4. Within developer options, scroll down to \"Debugging\" and toggle \"USB debugging\" to ON"
echo "5. Press the OK button when prompted to Allow USB debugging"
echo "6. Connect the handset to your computer via the USB-C port"
echo
echo "Ensure that the Sonim handset is connected"
echo
echo "The following applications will be installed:"
echo -e "TT9 (v61.0) \nZello (sonim-latest) \nF-Droid (latest) \nAurora Store (v4.8.1) \nDavX (v4.5.10-ose) \nMumla (v3.7.3) \nConversations (2.19.15+free) \nYubico Authenticator (v7.3.3) \n Binary Eye (v1.72.2) \nSignal-FOSS (v8.7.3.0-FOSS)"
echo
read -p "Continue? (Y/n): " continue

for cmd in adb wget; do
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "Error: Required command '$cmd' not found. Please install it."
		exit 1
	fi
done

if [[ "$continue" == "n" || "$continue" == "N" ]]; then
	echo "Terminating"
	exit 1
fi

# Check if device is actually connected
if ! adb get-state 1>/dev/null 2>&1; then
    echo "Error: No device connected or ADB is unauthorized. Check connection and try again."
    exit 1
fi

# Fetch and install apps
echo
echo "--- INSTALLING APPLICATIONS ---"
for entry in "${apk_list[@]}"; do
	IFS='|' read -r pkg_name url <<< "$entry"
	fetch_and_install "$pkg_name" "$url"
done

echo
echo "--- CONFIGURING SETTINGS ---"
# Setup TT9 keyboard
adb shell ime enable io.github.sspanak.tt9/.ime.TraditionalT9 >/dev/null 2>&1
adb shell ime set io.github.sspanak.tt9/.ime.TraditionalT9 >/dev/null 2>&1
verify_setting "secure" "default_input_method" "io.github.sspanak.tt9/.ime.TraditionalT9" "TT9: Set as Default Keyboard"

# Set F-Droid installer permissions
adb shell appops set --uid org.fdroid.fdroid REQUEST_INSTALL_PACKAGES allow 
appops_check=$(adb shell appops get org.fdroid.fdroid REQUEST_INSTALL_PACKAGES | grep -c "allow")
if [ "$appops_check" -eq 0 ]; then
	log_failure "Failed to set Install Permissions for F-Droid"
else
	echo "F-Droid: Set Install Permissions"
fi

# Set system-wide dark mode
adb shell settings put secure ui_night_mode 2
verify_setting "secure" "ui_night_mode" "2" "System: Dark Mode Enabled"

# Set system-wide font scale to small
adb shell settings put system font_scale 0.85
verify_setting "system" "font_scale" "0.85" "System: Font Size Set to Small"

# Setup Signal repo
echo "Opening Signal-FOSS F-Droid repo on handset..."
if ! adb shell am start -a android.intent.action.VIEW -d fdroidrepos://fdroid.twinhelix.com/fdroid/repo?fingerprint=7B03B0232209B21B10A30A63897D3C6BCA4F58FE29BC3477E8E3D8CF8E304028 >/dev/null 2>&1; then
	log_failure "Failed to open Signal-FOSS repo on handset"
fi

echo
echo "---------------------------------------------------"
# Post-install
if [ ${#failed_steps[@]} -eq 0 ]; then
	echo "HANDSET CONFIGURED SUCCESSFULLY"
	echo
	echo "Post-install steps are required:"
	echo "- Click the \"Add Repository\" button on the handset for Signal-FOSS"
	echo "- Restart the handset for Dark Mode to take effect"
else
	echo "SCRIPT FINISHED WITH ${#failed_steps[@]} ERROR(S)"
	echo "The following steps failed and require manual intervention:"
	for error in "${failed_steps[@]}"; do
		echo "- $error"
	done
fi
