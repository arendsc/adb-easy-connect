# adb-easy-connect
This bash script is used to interact with adb (Android Debug Bridge). It provides options to disconnect, scan network, scan ports and connect to a device, handling port changes automatically..

## Setup

1. Install adb (Android Debug Bridge) on your system. See the "Installing ADB" section below for instructions tailored to your specific operating system.
2. (Optional) Install nmap if you want to use the `-s` flag to scan the ports of the device. This is not necessary for connecting to the device, but it can simplify the process.
3. Install arp-scan to allow the script to scan the network.
4. Create a configuration file (`adb_config.txt`) in the same directory as the script. This file should contain the MAC address of the device.

## Requirements

- adb (Android Debug Bridge)
- arp-scan (for scanning network)
- (Optional) nmap (for scanning ports with the `-s` flag)

## Installing ADB (Android Debug Bridge)

ADB (Android Debug Bridge) is a versatile command-line tool that lets you communicate with a device. It is a part of the Android SDK Platform-Tools package, which you can install without the full SDK. Below are the steps to install ADB tailored to your specific operating system:

### Linux

#### Ubuntu (and other Debian-based distributions)

```bash
sudo apt update
sudo apt install adb
```

#### Fedora (and other RPM-based distributions)

```bash
sudo dnf update
sudo dnf install android-tools
```

#### Arch Linux (and other Arch-based distributions)

```bash
sudo pacman -Syu
sudo pacman -S android-tools
```

### macOS

If Homebrew isn't installed, run the following command:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then, install ADB by running:

```bash
brew install android-platform-tools
```

### Windows

1. Visit the [Android SDK Platform-Tools](https://developer.android.com/studio/releases/platform-tools) download page.
2. Click on the SDK Platform-Tools for Windows link to download the zip file.
3. Extract the zip file to a location on your computer, such as `C:\platform-tools`.
4. Add the `platform-tools` directory to your system's path.
5. Verify the installation by opening a new Command Prompt window and running `adb version`. If it says `'adb' is not recognized as an internal or external command, operable program or batch file`, ensure that you have added the `platform-tools` directory to your system's PATH correctly.

## Options

- `-d` Disconnect from adb
- `-s` Scan the ports of the device (requires nmap)
- `-i` Set the IP address of the device
- `-h` Display the help message
- `--help` Same as `-h`

If no option is provided, the script will try to connect to the device on the standard port (5555). If it fails, it will prompt the user to enter a port, and then try to connect on that port. If it still fails, it will exit with an error message.

## Usage Examples

- Disconnect from adb: `./adb_script.sh -d`
- Scan the ports of the device: `./adb_script.sh -s`
- Set the IP address of the device: `./adb_script.sh -i 192.168.1.2`
- Run the script without any flags (tries to connect to the device): `./adb_script.sh`

## Configuration

The script expects a configuration file (`adb_config.txt`) in the same directory, which should contain the MAC address of the device. A sample configuration file (`adb_config_sample.txt`) is provided. Copy this file to `adb_config.txt` and replace the placeholder MAC address with the actual MAC address of your device. If the configuration file is not found, the script will exit with an error message. If the configuration file does not contain an IP address, the script will try to scan the network using arp-scan to find the IP address. If arp-scan is not installed, the script will exit with an error message.
