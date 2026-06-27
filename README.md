# 🎯 MediaTek MT7902 WiFi & Bluetooth Driver for Linux (✅ Working)
Out-of-tree driver for the MediaTek MT7902 WiFi 6E chip, ported and patched for modern Linux kernels.

## ✅ Tested On (Verified Working)
This fix has been verified and is confirmed working on:

* **Brand:** ASUS
* **Model:** Vivobook Go (E1404FA)
* **Chipset:** MediaTek MT7902 (WiFi 6E / Filogic 310)
* **Kernel Version:** 6.12 – 7.x
* **OS:** Ubuntu 24.04, EndeavourOS (Arch-based), and similar distros

## 🚀 Easy Automatic Fix (Recommended)
If you want to quickly fix your WiFi and Bluetooth on any modern kernel, follow these steps:

1. **Open your terminal** and clone the repository:
   ```bash
   git clone --depth 1 https://github.com/SkimerPM/MediaTek-MT7902-WiFi-Driver-for-Linux-Kernel-6.12-
   cd MediaTek-MT7902-WiFi-Driver-for-Linux-Kernel-6.12-
   ```

2. **Give the script execution permission:**
   ```bash
   chmod +x fix_my_wifi.sh
   ```

3. **Run the script with sudo:**
   ```bash
   sudo bash fix_my_wifi.sh
   ```

   The script is **interactive** — it will auto-detect your country and confirm each step before doing anything.

   **🌎 Prefer Spanish? / ¿Prefieres en español?**
   ```bash
   chmod +x instalar_wifi.sh
   sudo bash instalar_wifi.sh
   ```

   **Non-interactive mode (for advanced users / scripts):**
   ```bash
   # Pass your country code directly (PE=Peru, US, MX, AR, BR, CL, CO...)
   sudo bash fix_my_wifi.sh --country PE

   # Spanish version with country code
   sudo bash instalar_wifi.sh --pais PE

   # Uninstall everything (requires Ethernet backup connection)
   sudo bash fix_my_wifi.sh --uninstall
   ```

### 📖 What this script does:
* **Distro detection:** Supports Debian / Ubuntu / Mint **and** Arch / Manjaro / EndeavourOS / CachyOS / Garuda automatically.
* **Installs via DKMS:** Driver is registered with DKMS — it **auto-recompiles after every kernel update**. No manual action needed.
* **Regulatory domain (country code):** Sets the legal WiFi channel and power limits for your country. Auto-detected from your system locale. Persists across reboots.
* **Bluetooth firmware fix:** Detects and resolves the known firmware path conflict that prevents BT from initializing.
* **Loads immediately:** No reboot required — WiFi and Bluetooth activate right after installation.
* **Verifies:** Post-install check confirms all modules and firmware are correctly in place.

> [!NOTE]
> You will need an internet connection (via Ethernet or USB tethering from your phone) the first time you run this to download the necessary build tools.

> [!WARNING]
> Before running `--uninstall`, make sure you have an **Ethernet cable or another internet connection** available. The script will warn you and ask for confirmation before removing anything.

## 🔧 Firmwares used
Firmwares are stored in `mt7902_firmware` folder.
Recently released firmware are in the `mt7902_firmware/latest` folder.

## 📁 Cloning the repository
Clone the repository to your local PC:
  ```bash
  git clone https://github.com/SkimerPM/MediaTek-MT7902-WiFi-Driver-for-Linux-Kernel-6.12-
  ```
If you don't want to clone past history:
  ```bash
  git clone --depth 1 https://github.com/SkimerPM/MediaTek-MT7902-WiFi-Driver-for-Linux-Kernel-6.12-
  ```


## 📱 Bluetooth ✅ (Working)
> [!WARNING]
> If bluetooth driver conflict with `gen4-mt7902` than please remove the bluetooth firmware so that it not interfere with this driver
> ``` sudo rm /lib/firmware/mediatek/mt7902/BT_RAM_CODE_MT7902_1_1_hdr.bin.zst ```
> This project uses the firmware
> ``` /lib/firmware/mediatek/BT_RAM_CODE_MT7902_1_1_hdr.bin.zst ```

To enable bluetooth go to the directory of your current kernel version. ``
Like if you have kernel linux-6.16 than go to the directory `./linux-6.16/drivers/bluetooth` .
Open terminal in this directory and compile with command `make`.
Two kernel modules are compiled `btusb.ko` and `btmtk.ko`.
To enable bluetooth in your device remove the btusb and btmtk in your system and install these two files, use commands
```
sudo rmmod btusb 
sudo rmmod btmtk

sudo insmod btmtk.ko
sudo insmod btusb.ko

```
Now check your bluetooth is working now.

## 💻 WiFi ✅ (Working)
> [!IMPORTANT]
> A working repo with some limitation is [here](https://github.com/hmtheboy154/gen4-mt7902)

WiFi driver for the mt7902, recently released by mediatek is inside the `latest` folder. 

If you are using Ubuntu than just go to the `latest` folder and run the following command in the termianl. 
```
make
```

It will compile all modules, compress it and install it (replace original kernel module with the modified module). If you are some other distro or not want all steps and only wants to compile the code, than run in the termianl 
```
make module_compile
```
To compress the module you compiled, than run in terminal
```
make module_compress
```
To install the compressed module to the system's kernel module, run in terminal
```
make module_install
```
