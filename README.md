# adb-easy-connect

`adb-easy-connect.sh` simplifies connecting to an Android device over wireless ADB, allowing you to connect without manually entering a port.
Instead of looking up the phone's current IP address manually, the script resolves it from the phone's MAC address. It can also automatically determine the active port on your phone and connect to it with `adb`.

## Requirements

- `adb` from the Android SDK Platform-Tools: https://developer.android.com/tools/releases/platform-tools
- `arp-scan` to discover the device IP on your local network
- Optional: `nmap` if you want to use `-s` to scan for the current ADB port

## Initial Android Setup

For the initial wireless ADB setup, you need to pair your phone with your computer once:

1. Enable Developer Options on the device.
2. Follow Google's wireless debugging pairing steps for Android 11+:
   https://developer.android.com/tools/adb#wireless-android11-command-line
3. After pairing, enable the Quick Settings developer tiles for Wireless debugging:
   https://developer.android.com/studio/debug/dev-options#general

After that initial setup, you can forget the manual pairing workflow and just use this script to reconnect.

## Configuration

The script expects an `adb_config.txt` file in the same directory. It must contain the device MAC address.

An example is included in `adb_config_sample.txt`:

```sh
MAC_ADDRESS='xx:xx:xx:xx:xx:xx'
```

Copy it to `adb_config.txt` and replace the placeholder with your phone's MAC address.

If `IP_ADDRESS` is not present in the config, the script will use `arp-scan` to find the device on the network and update the config automatically.

## Usage

Typical workflow:

1. Enable Wireless debugging on your phone using the Developer Options quick settings tile.
2. Run `./adb-easy-connect.sh` on your computer.
3. Use the ADB connection for whatever you need. I mostly use the following tools:
   [scrcpy](https://github.com/Genymobile/scrcpy) or
   [better-adb-sync](https://github.com/jb2170/better-adb-sync).
4. Disconnect with `./adb-easy-connect.sh -d`.
5. Disable the Wireless debugging tile again.

```sh
./adb-easy-connect.sh
```

I highly recommend installing `nmap` and using `./adb-easy-connect.sh -s`, because the wireless debugging port changes after each phone restart. With `nmap`, the script scans for the active port automatically, so you never have to type a port again.

If you do not want to use `nmap`, you will have to open the Wireless debugging settings on the phone and enter the current port after each restart.

After connecting through a changed port once, the script switches the device back to the standard ADB TCP port `5555`.

### Options

- `-d` Disconnect from ADB
- `-s` Scan the device for open ADB ports with `nmap`
- `-i <ip>` Use a specific IP address instead of scanning
- `-h`, `--help` Show the help message

## Examples

```sh
./adb-easy-connect.sh
./adb-easy-connect.sh -d
./adb-easy-connect.sh -s
./adb-easy-connect.sh -i 192.168.1.2
```
