# 🎯 MediaTek MT7902 WiFi & Bluetooth Driver for Linux (✅ Working)
Out-of-tree driver for the MediaTek MT7902 WiFi 6E chip, ported and patched for modern Linux kernels.

## ✅ Tested On (Verified Working)
This fix has been verified and is confirmed working on:
* **Brand:** ASUS
* **Model:** Vivobook Go (E1404FA)
* **Chipset:** MediaTek MT7902 (WiFi 6E / Filogic 310)
* **Kernel Version:** 6.12 – 7.x
* **OS:** Ubuntu 24.04, EndeavourOS (Arch-based), and similar distros

---

## 🇬🇧 English Instructions: Easy Automatic Fix (Recommended)
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
   *The script is **interactive** — it will auto-detect your country and confirm each step before doing anything.*

### 📖 What this script does:
* **Distro detection:** Supports **any Debian-based** distro (Debian, Ubuntu, Mint, Pop!_OS, Zorin, etc.) and **any Arch-based** distro (Arch, Manjaro, EndeavourOS, Garuda, CachyOS, etc.) automatically.
* **Installs via DKMS:** Driver is registered with DKMS — it **auto-recompiles after every kernel update**. No manual action needed.
* **Regulatory domain (country code):** Sets the legal WiFi channel and power limits for your country. Auto-detected from your system locale. Persists across reboots.
* **Bluetooth firmware fix:** Detects and resolves the known firmware path conflict that prevents BT from initializing.
* **Loads immediately:** No reboot required — WiFi and Bluetooth activate right after installation.

> [!NOTE]
> You will need an internet connection (via Ethernet or USB tethering from your phone) the first time you run this to download the necessary build tools.

---

## 🇪🇸 Instrucciones en Español: Solución Automática (Recomendada)
Si quieres arreglar rápidamente tu WiFi y Bluetooth en cualquier kernel moderno, sigue estos pasos:

1. **Abre tu terminal** y clona el repositorio:
   ```bash
   git clone --depth 1 https://github.com/SkimerPM/MediaTek-MT7902-WiFi-Driver-for-Linux-Kernel-6.12-
   cd MediaTek-MT7902-WiFi-Driver-for-Linux-Kernel-6.12-
   ```

2. **Dale permisos de ejecución al script:**
   ```bash
   chmod +x instalar_wifi.sh
   ```

3. **Ejecuta el script con sudo:**
   ```bash
   sudo bash instalar_wifi.sh
   ```
   *El script es **interactivo** — detectará tu país automáticamente y te pedirá confirmación antes de instalar.*

### 📖 ¿Qué hace este script?:
* **Detección de distribución:** Soporta automáticamente **cualquier distro basada en Debian** (Debian, Ubuntu, Mint, Pop!_OS, Zorin, etc.) y **cualquier distro basada en Arch** (Arch, Manjaro, EndeavourOS, Garuda, CachyOS, etc.).
* **Instalación vía DKMS:** El driver sobrevive a las actualizaciones. Se **recompilará solo cada vez que actualices el kernel**.
* **Código de país (Regulatory domain):** Configura los canales WiFi legales y la potencia máxima para tu país, mejorando la señal.
* **Arreglo de Bluetooth:** Detecta y resuelve el conflicto de firmware que impide que el Bluetooth encienda en este chip.
* **Carga instantánea:** No necesitas reiniciar la PC — el WiFi y Bluetooth se activarán apenas termine la instalación.

> [!NOTE]
> Necesitarás una conexión a internet (por cable de red Ethernet o compartiendo datos desde tu celular por USB) la primera vez que ejecutes esto para descargar las herramientas de compilación.

---

## 🗑️ Uninstalling / Desinstalar
If you need to completely remove the driver and restore your system / Si necesitas eliminar el driver por completo:

```bash
# English
sudo bash fix_my_wifi.sh --uninstall

# Español
sudo bash instalar_wifi.sh --desinstalar
```
> [!WARNING]
> Before uninstalling, make sure you have an Ethernet cable or backup internet connection available.
> Antes de desinstalar, asegúrate de tener un cable de red u otra conexión a internet de respaldo.

---

## 🔧 Advanced / Scripts (Non-interactive)
You can pass the country code directly to bypass the interactive prompts (e.g., `PE` for Peru, `US`, `MX`, `ES`):
```bash
sudo bash fix_my_wifi.sh --country PE
sudo bash instalar_wifi.sh --pais PE
```

## 📁 Firmware
Firmwares are stored in the `mt7902_firmware` folder. The installation script will automatically copy them to `/lib/firmware/mediatek/` and resolve any path conflicts for you.
