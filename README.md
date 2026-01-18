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

## Auto-Updates

The app automatically checks for updates on startup. When an update is available, you'll see a notification banner with the option to install immediately.

## Source Code

This is a releases-only repository. For issues or feature requests, contact support.

## Website

Visit [tapselo.com](https://tapselo.com) for more information.
