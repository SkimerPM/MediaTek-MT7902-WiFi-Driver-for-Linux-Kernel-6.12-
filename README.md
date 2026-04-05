# MediaTek MT7902 WiFi Driver for Linux (Kernel 6.12+)

![License](https://img.shields.io/badge/license-GPL--2.0-blue.svg)
![Kernel](https://img.shields.io/badge/kernel-%3E%3D%206.12-brightgreen.svg)

A dynamically patched, working out-of-tree driver for the notoriously difficult **MediaTek MT7902 WiFi adapter**, fully adapted to compile and run on modern Linux kernels (specifically 6.12 and later).

## ⚠️ The Problem
The MT7902 chip is shipped in many modern laptops (ASUS, HP, Lenovo). However, the manufacturer's provided out-of-tree drivers are mostly abandoned, tied to ancient Linux kernel APIs, and break drastically on modern kernels (6.x+). This leaves thousands of users without WiFi.

## ✅ The Fix
This repository contains a heavily refactored version of the MT76 stack with surgical modifications:
- Stubbed out missing Airoha NPU dependencies (`airoha_npu_tx_dma_desc`, etc.) absent in newer kernels.
- Modernized the Netmem / Page Pool APIs for kernel 6.12+ compatibility.
- Replaced deprecated timer macros (e.g. `timer_container_of` to `from_timer`).
- Patched mismatched `ieee80211_ops` callback signatures (removed upstream `radio_idx` and `link_id` parameter changes).
- **Performance Fix (MIMO 2x2):** Forced `antenna_mask=3` to enable both physical antennas, significantly improving signal strength (-81dBm to -69dBm) and TX bitrates.
- **Bluetooth Support:** Integrated patched `btusb` and `btmtk` modules for full Bluetooth 5.2 functionality on Kernel 6.12.
- Full `dkms.conf` support for automatic rebuilds on kernel updates (WiFi + BT).

## 🏆 Acknowledgments
This project would not have been possible without the assistance of **Antigravity (AI)**, who helped debug, modernize, and surgically patch the code for the most modern Linux kernels.

Special thanks also to [abdullaabdullazade](https://github.com/abdullaabdullazade/mt7902_driver) for the base Bluetooth patches.

## 🚀 Installation (The DKMS Way - Highly Recommended)

By using DKMS, this driver will automatically re-compile itself silently in the background every time your Linux system gets a kernel update. You'll never lose WiFi again.

### 1. Requirements
Ensure you have the build essentials and DKMS installed:
```bash
sudo apt update
sudo apt install dkms build-essential linux-headers-$(uname -r)
```

### 2. Firmware Notice
You **must** have the Mediatek Firmware files installed in your system for the card to power on. Place the `.bin` files (`WIFI_RAM_CODE_MT7902_1.bin`, etc.) in `/lib/firmware/mediatek/`. *(Make sure to extract them from official sources or your previous driver folder).*

### 3. Install
Clone this repository and install using DKMS:

```bash
# Clone the repository
git clone https://github.com/SkimerPM/MediaTek-MT7902-WiFi-Driver-for-Linux-Kernel-6.12-.git mt7902-wifi-1.0
cd mt7902-wifi-1.0

# Copy to the system source directory
sudo cp -r . /usr/src/mt7902-wifi-1.0

# Register with DKMS
sudo dkms add -m mt7902-wifi -v 1.0

# Build and Install
sudo dkms build -m mt7902-wifi -v 1.0
sudo dkms install -m mt7902-wifi -v 1.0
```

### 4. Enable the module
Reboot your PC, or manually load the module into the current session:
```bash
sudo modprobe mt7921e
```

Enjoy your WiFi! 🥂
