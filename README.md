# Sonim XP5plus 5G Automated Setup
Automates app installation and setup for the Sonim XP5plus 5G 

# Description
* Walks the user through enabling developer mode
* Installs and automatically configures Traditional T9 keyboard
* Installs F-Droid and sets app installation permissions
* Enables system-wide dark mode
* Installs Signal-FOSS and guides the user through F-Droid repo installation
* Installs the Sonim specific build for Zello
* Installs Aurora Store for anonymous Play Store app downloads
* Installs DAVx^(5) for Contacts and Calendar synchronization via CardDAV/CalDAV
* Installs Mumla, a Mumble voice chat client
* Installs Conversations, an encrypted XMPP instant messenger
* Installs Yubico Authenticator for YubiKey two-factor authentication code generation
* Installs Binary Eye QR code reader
* Installs GPS Cockpit, a GPS coordinate display

# Prequesites
* A Sonim XP5plus 5G
* USB Cable
* PC running Linux or Unix (with an active internet connection)
* adb, wget and bash installed on PC

# Instructions
1. Download script to your PC
2. Make script executable ``chmod 700 sonim_xp5p5g_setup.sh``
3. Connect phone to your PC via the USB-C port
4. Execute the script with ``./sonim_xp5p5g_setup.sh`` and follow the on-screen instructions
5. Profit

# Software versions installed
* TT9 (v61.0)
* Zello (latest) 
* F-Droid (latest)
* Aurora Store (v4.8.1) 
* DAVx5 (v4.5.10-ose) 
* Mumla (v3.7.3)
* Conversations (2.19.15+free)
* Yubico Authenticator (v7.3.3)
* Binary Eye (v1.72.2)
* Signal (v8.7.3.0-FOSS)
