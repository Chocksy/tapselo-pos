# Tapselo POS Downloads

This repository hosts releases for Tapselo POS System.

## System Requirements

| Platform | Minimum Version | RAM | Processor |
|----------|-----------------|-----|-----------|
| Windows | Windows 10 (1803+) or Windows 11 | 4 GB | Dual-core |
| macOS | macOS 10.13+ (High Sierra) | 4 GB | Intel or Apple Silicon |
| Linux | Ubuntu 20.04+ / Debian 10+ | 2 GB (4 GB recommended) | Dual-core |

> **Note:** Windows 7/8/8.1 are **not supported** due to WebView2 requirements.

### Linux Recommended Distributions

For older hardware (4GB RAM), lightweight distributions work best:
- **Xubuntu 22.04 LTS** (recommended)
- **Lubuntu 22.04 LTS**
- **Ubuntu MATE 22.04 LTS**

Tested hardware: Dell OptiPlex 790 (Intel Core i5, 4GB RAM) with USB touchscreen.

## Download

Visit the [Releases page](../../releases) to download the latest version for your platform:

| Platform | Format | Notes |
|----------|--------|-------|
| Windows | `.msi` installer | Requires Windows 10+ |
| macOS (Intel) | `.dmg` | For Intel-based Macs |
| macOS (Apple Silicon) | `.dmg` | For M1/M2/M3 Macs |
| Linux | `.AppImage` | Make executable and run |
| USB Kiosk | `.img.gz` | Bootable USB image for dedicated POS hardware |

## Installation

**Windows**: Run the `.msi` installer (requires administrator privileges)

**macOS**: Open the `.dmg` file and drag the app to Applications

**Linux**: 
```bash
chmod +x Tapselo.POS_*.AppImage
./Tapselo.POS_*.AppImage
```

### Linux Touchscreen Setup

USB touchscreens typically work out of the box. If calibration is needed:
```bash
sudo apt install xinput-calibrator
xinput_calibrator
```

## USB Kiosk Image (Dedicated POS Hardware)

For dedicated POS terminals, we provide a pre-built bootable USB image based on Debian with the POS app pre-installed. Boot from USB and the kiosk starts automatically — no OS installation needed.

### Flash USB with One Command

Prerequisites: [GitHub CLI](https://cli.github.com/) (`gh`) installed and authenticated.

```bash
# Download the flash script
curl -fsSL https://raw.githubusercontent.com/Chocksy/tapselo-pos/main/scripts/flash-usb.sh -o flash-usb.sh
chmod +x flash-usb.sh

# Flash the latest release
./flash-usb.sh

# Or flash a specific version
./flash-usb.sh v0.6.9
```

Works on **macOS** and **Linux**. The script will:

1. Fetch the latest USB image from GitHub Releases (~1.5 GB compressed)
2. Show available external disks and ask you to pick the target
3. Require `YES` confirmation before writing (rejects system disks)
4. Flash the image with a progress bar (install `pv` for best experience)
5. Clean up the downloaded image to save disk space

> **Tip:** Install `pv` for a nice progress bar: `brew install pv` (macOS) or `apt install pv` (Linux).

### What's on the USB Image

- Debian 13 minimal + X11 + Openbox (auto-login, no desktop environment)
- Tapselo POS app starts fullscreen on boot
- FAT32 log partition (`POS-LOGS`) readable on any OS — pull the USB to check logs
- SSH enabled: `ssh pos@<ip>` (password: `pos`)
- Auto-updates: the app checks for updates on startup

### At the Store

1. Plug USB into PC
2. Boot from USB (F12/F2/Del for boot menu)
3. POS kiosk starts automatically
4. Connect to WiFi or Ethernet for initial activation

## Auto-Updates

The app automatically checks for updates on startup. When an update is available, you'll see a notification banner with the option to install immediately.

## Source Code

This is a releases-only repository. For issues or feature requests, contact support.

## Website

Visit [tapselo.com](https://tapselo.com) for more information.
