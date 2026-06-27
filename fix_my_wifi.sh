#!/bin/bash
# ============================================================
#  🎯 MT7902 WiFi & Bluetooth — Universal Installer v2.0
# ============================================================
#  Supports: Debian / Ubuntu / Mint  AND  Arch / Manjaro /
#            EndeavourOS / CachyOS / Garuda
#
#  FEATURES:
#   ✅ DKMS — driver survives kernel updates automatically
#   ✅ WiFi regulatory domain (country code) for max signal
#   ✅ Bluetooth patched modules (btusb + btmtk)
#   ✅ BT firmware conflict resolution
#   ✅ Post-install verification
#   ✅ Uninstall mode (--uninstall)
#
#  USAGE:
#   sudo bash fix_my_wifi.sh              (interactive)
#   sudo bash fix_my_wifi.sh --country PE (non-interactive, Peru)
#   sudo bash fix_my_wifi.sh --uninstall  (remove everything)
#
#  REQUIREMENTS:
#   - Internet connection for first run (ethernet or USB tethering)
#   - Run as root (sudo)
# ============================================================

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}ℹ️  $*${RESET}"; }
success() { echo -e "${GREEN}✅ $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠️  $*${RESET}"; }
error()   { echo -e "${RED}❌ $*${RESET}" >&2; exit 1; }
step()    { echo -e "\n${BOLD}${CYAN}▶ $*${RESET}"; }

# ── Sanity checks ────────────────────────────────────────────
[[ $EUID -ne 0 ]] && error "Run this script with sudo: sudo bash $0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRIVER_SRC="$SCRIPT_DIR/latest"
[[ ! -d "$DRIVER_SRC" ]] && error "Driver source not found at '$DRIVER_SRC'. Are you in the mt7902_temp directory?"

# ── Argument parsing ─────────────────────────────────────────
COUNTRY_ARG=""
UNINSTALL=false
for arg in "$@"; do
    case "$arg" in
        --uninstall) UNINSTALL=true ;;
        --country)   shift; COUNTRY_ARG="${1:-}" ;;
        --country=*) COUNTRY_ARG="${arg#--country=}" ;;
    esac
done

# ── Distro detection ─────────────────────────────────────────
detect_distro() {
    local id="" id_like=""
    if [[ -f /etc/os-release ]]; then
        id=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
        id_like=$(grep -E '^ID_LIKE=' /etc/os-release | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
    fi

    IS_ARCH=false; IS_DEBIAN=false; IS_CACHYOS=false; PKG_MGR=""

    if echo "$id $id_like" | grep -qE 'arch|manjaro|endeavouros|garuda|cachyos'; then
        IS_ARCH=true; PKG_MGR="pacman"
        echo "$id" | grep -q 'cachyos' && IS_CACHYOS=true
    elif echo "$id $id_like" | grep -qE 'debian|ubuntu|mint|pop|linuxmint'; then
        IS_DEBIAN=true; PKG_MGR="apt"
    else
        error "Unsupported distro: '$id'. Tested on Debian/Ubuntu/Arch families."
    fi

    DISTRO_NAME=$(grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null \
                  | cut -d= -f2 | tr -d '"' || echo "$id")
}

# ── UNINSTALL mode ───────────────────────────────────────────
do_uninstall() {
    echo ""
    echo -e "${RED}${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}${BOLD}║  ⚠️  ADVERTENCIA / WARNING                           ║${RESET}"
    echo -e "${RED}${BOLD}║  Esto eliminará los drivers de WiFi y Bluetooth.     ║${RESET}"
    echo -e "${RED}${BOLD}║  Si no tienes Ethernet u otra conexión activa,       ║${RESET}"
    echo -e "${RED}${BOLD}║  PERDERÁS el acceso a internet tras la desinstalación ║${RESET}"
    echo -e "${RED}${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
    read -rp "  ¿Tienes Ethernet u otra conexión de respaldo activa? [s/N]: " net_ok
    [[ "${net_ok,,}" != "s" && "${net_ok,,}" != "y" ]] && {
        info "Desinstalación cancelada. Conecta un cable de red primero si quieres continuar."
        exit 0
    }
    echo ""
    warn "Última oportunidad — esta acción desinstalará WiFi y Bluetooth."
    read -rp "  Escribe 'CONFIRMAR' para continuar: " double_check
    [[ "$double_check" != "CONFIRMAR" ]] && { info "Cancelado."; exit 0; }

    step "Uninstalling MT7902 driver..."

    # DKMS removal
    if command -v dkms &>/dev/null && dkms status | grep -q 'mt7902-wifi'; then
        info "Removing DKMS module..."
        dkms remove mt7902-wifi/1.0 --all 2>/dev/null || true
        rm -rf /usr/src/mt7902-wifi-1.0
        success "DKMS module removed."
    fi

    # Systemd service (legacy)
    if systemctl list-unit-files mt7902.service &>/dev/null 2>&1; then
        systemctl stop mt7902.service 2>/dev/null || true
        systemctl disable mt7902.service 2>/dev/null || true
        rm -f /etc/systemd/system/mt7902.service
        systemctl daemon-reload
    fi
    rm -f /usr/local/bin/mt7902-setup.sh

    # Legacy custom modules dir
    rm -rf /lib/modules/mt7902_custom

    # Regulatory domain
    if [[ -f /etc/conf.d/wireless-regdom ]]; then
        warn "Keeping /etc/conf.d/wireless-regdom (regulatory domain). Remove manually if needed."
    fi
    if [[ -f /etc/default/crda ]]; then
        warn "Keeping /etc/default/crda (regulatory domain). Remove manually if needed."
    fi

    success "Uninstall complete. You may need to reboot."
    exit 0
}

# ── Install dependencies ─────────────────────────────────────
install_deps() {
    step "Installing build dependencies for $DISTRO_NAME..."
    if $IS_DEBIAN; then
        apt-get update -qq
        apt-get install -y \
            build-essential \
            "linux-headers-$(uname -r)" \
            dkms \
            bc \
            wireless-regdb \
            iw \
            2>/dev/null
    elif $IS_ARCH; then
        local pkgs=(base-devel dkms iw wireless-regdb)
        $IS_CACHYOS && pkgs+=(clang llvm lld)
        # Add linux-headers for the running kernel
        local hdr_pkg=""
        if uname -r | grep -q 'cachyos'; then
            hdr_pkg="linux-cachyos-headers"
        elif uname -r | grep -q 'lts'; then
            hdr_pkg="linux-lts-headers"
        elif uname -r | grep -q 'zen'; then
            hdr_pkg="linux-zen-headers"
        elif uname -r | grep -q 'hardened'; then
            hdr_pkg="linux-hardened-headers"
        else
            hdr_pkg="linux-headers"
        fi
        pkgs+=("$hdr_pkg")
        pacman -S --needed --noconfirm "${pkgs[@]}"
    fi
    success "Dependencies installed."
}

# ── Regulatory domain ─────────────────────────────────────────
configure_regdom() {
    step "Configuring WiFi Regulatory Domain (country code)..."
    info "This sets the legal power limits and allowed channels for your country."
    info "Wrong country = signal artificially capped by the kernel."

    local country="$COUNTRY_ARG"

    if [[ -z "$country" ]]; then
        # Priority 1: already configured in system files
        local current=""
        if [[ -f /etc/conf.d/wireless-regdom ]]; then
            current=$(grep -oP '(?<=WIRELESS_REGDOM=")[A-Z]{2}' /etc/conf.d/wireless-regdom 2>/dev/null || true)
        elif [[ -f /etc/default/crda ]]; then
            current=$(grep -oP '(?<=REGDOMAIN=)[A-Z]{2}' /etc/default/crda 2>/dev/null || true)
        fi

        # Priority 2: detect from system locale (e.g. es_PE.UTF-8 → PE)
        if [[ -z "$current" ]]; then
            local locale_country
            locale_country=$(locale 2>/dev/null | grep -E '^LANG=' \
                | grep -oP '[a-z]{2}_\K[A-Z]{2}(?=\.)' | head -1 || true)
            [[ -n "$locale_country" ]] && current="$locale_country" && \
                info "Country auto-detected from system locale: '$current'"
        fi

        if [[ -n "$current" ]]; then
            warn "Detected country code: '$current'"
            read -rp "  Use '$current'? [Y/n]: " ans
            [[ "${ans,,}" == "n" ]] || { country="$current"; }
        fi

        if [[ -z "$country" ]]; then
            echo ""
            echo "  Common codes: US, PE, MX, AR, BR, CO, CL, ES, GB, DE, FR, JP"
            read -rp "  Enter your 2-letter country code [default: US]: " country
            country="${country:-US}"
        fi
    fi

    # Validate: 2 uppercase letters
    country="${country^^}"
    [[ "$country" =~ ^[A-Z]{2}$ ]] || error "Invalid country code: '$country'. Use 2 letters like PE, US, MX."

    info "Setting regulatory domain to: $country"

    # Apply immediately
    if command -v iw &>/dev/null; then
        iw reg set "$country" && success "Regulatory domain set to '$country' (active now)." \
                              || warn "Could not apply immediately — will apply on next boot."
    fi

    # Persist on Arch/systemd-based
    if $IS_ARCH; then
        mkdir -p /etc/conf.d
        echo "WIRELESS_REGDOM=\"$country\"" > /etc/conf.d/wireless-regdom
        # Enable the service that reads this file
        if systemctl list-unit-files wireless-regdom.service &>/dev/null 2>&1; then
            systemctl enable --now wireless-regdom.service 2>/dev/null || true
        fi
        success "Regulatory domain '$country' persisted to /etc/conf.d/wireless-regdom"
    fi

    # Persist on Debian/Ubuntu
    if $IS_DEBIAN; then
        if [[ -f /etc/default/crda ]]; then
            sed -i "s/^REGDOMAIN=.*/REGDOMAIN=$country/" /etc/default/crda
        else
            echo "REGDOMAIN=$country" > /etc/default/crda
        fi
        success "Regulatory domain '$country' persisted to /etc/default/crda"
    fi

    # Also write to modprobe for cfg80211 — works on both distros
    mkdir -p /etc/modprobe.d
    echo "options cfg80211 ieee80211_regdom=$country" > /etc/modprobe.d/cfg80211.conf
    success "cfg80211 module option set (ensures domain loads with WiFi driver)."

    COUNTRY_CODE="$country"
}

# ── Handle BT firmware conflict ───────────────────────────────
handle_bt_firmware() {
    step "Checking Bluetooth firmware conflicts..."
    local conflict_fw="/lib/firmware/mediatek/mt7902/BT_RAM_CODE_MT7902_1_1_hdr.bin.zst"
    local correct_fw="/lib/firmware/mediatek/BT_RAM_CODE_MT7902_1_1_hdr.bin.zst"

    if [[ -f "$conflict_fw" ]]; then
        warn "Conflicting BT firmware detected at: $conflict_fw"
        warn "This interferes with the patched driver and may cause Bluetooth failure."
        read -rp "  Remove conflicting firmware? [Y/n]: " ans
        if [[ "${ans,,}" != "n" ]]; then
            rm -f "$conflict_fw"
            success "Conflicting firmware removed."
        else
            warn "Skipped — Bluetooth may not work correctly."
        fi
    else
        success "No BT firmware conflicts found."
    fi

    if [[ ! -f "$correct_fw" ]]; then
        warn "Expected BT firmware not found: $correct_fw"
        info "Checking project firmware folder..."
        local fw_src="$SCRIPT_DIR/mt7902_firmware"
        local bt_bin
        bt_bin=$(find "$fw_src" -name "BT_RAM_CODE_MT7902_1_1_hdr.bin*" 2>/dev/null | head -1)
        if [[ -n "$bt_bin" ]]; then
            mkdir -p /lib/firmware/mediatek
            cp "$bt_bin" /lib/firmware/mediatek/
            success "BT firmware installed from project folder."
        else
            warn "BT firmware not found in project. Bluetooth might not initialize."
        fi
    else
        success "BT firmware present: $correct_fw"
    fi
}

# ── DKMS installation ─────────────────────────────────────────
install_dkms() {
    step "Installing driver via DKMS (survives kernel updates)..."

    local dkms_src="/usr/src/mt7902-wifi-1.0"
    local MODULE="mt7902-wifi"
    local VERSION="1.0"

    # Remove stale DKMS entry if exists
    if dkms status | grep -q "$MODULE/$VERSION"; then
        info "Removing previous DKMS entry..."
        dkms remove "$MODULE/$VERSION" --all 2>/dev/null || true
    fi

    # Clean old install dir
    rm -rf "$dkms_src"

    # Copy source to DKMS tree
    info "Copying driver source to $dkms_src ..."
    mkdir -p "$dkms_src"
    # Use rsync if available, otherwise cp (exclude build artifacts for cleanliness)
    if command -v rsync &>/dev/null; then
        rsync -a --exclude='*.o' --exclude='*.ko' --exclude='*.ko.zst' \
              --exclude='.tmp_versions' --exclude='Module.symvers' \
              --exclude='modules.order' --exclude='.git' \
              "$DRIVER_SRC/" "$dkms_src/"
    else
        cp -a "$DRIVER_SRC/." "$dkms_src/"
    fi

    # Ensure dkms.conf is present (use project one or generate)
    if [[ ! -f "$dkms_src/dkms.conf" ]]; then
        warn "dkms.conf not found in source, generating one..."
        cat > "$dkms_src/dkms.conf" << 'DKMSEOF'
PACKAGE_NAME="mt7902-wifi"
PACKAGE_VERSION="1.0"
MAKE[0]="make -C $kernel_source_dir M=$dkms_tree/$PACKAGE_NAME/$PACKAGE_VERSION/build modules"
CLEAN="make clean"
BUILT_MODULE_NAME[0]="mt76"
DEST_MODULE_LOCATION[0]="/updates/mt76"
BUILT_MODULE_NAME[1]="mt76-connac-lib"
DEST_MODULE_LOCATION[1]="/updates/mt76"
BUILT_MODULE_NAME[2]="mt792x-lib"
DEST_MODULE_LOCATION[2]="/updates/mt76"
BUILT_MODULE_NAME[3]="mt7921-common"
BUILT_MODULE_LOCATION[3]="mt7921/"
DEST_MODULE_LOCATION[3]="/updates/mt76"
BUILT_MODULE_NAME[4]="mt7921e"
BUILT_MODULE_LOCATION[4]="mt7921/"
DEST_MODULE_LOCATION[4]="/updates/mt76"
BUILT_MODULE_NAME[5]="btmtk"
BUILT_MODULE_LOCATION[5]="bluetooth/"
DEST_MODULE_LOCATION[5]="/updates/bluetooth"
BUILT_MODULE_NAME[6]="btusb"
BUILT_MODULE_LOCATION[6]="bluetooth/"
DEST_MODULE_LOCATION[6]="/updates/bluetooth"
AUTOINSTALL="yes"
DKMSEOF
    fi

    # For CachyOS: patch MAKE command to use clang
    if $IS_CACHYOS; then
        info "CachyOS detected — configuring clang compiler in DKMS..."
        sed -i 's|MAKE\[0\]=.*|MAKE[0]="make CC=clang LD=ld.lld -C $kernel_source_dir M=$dkms_tree/$PACKAGE_NAME/$PACKAGE_VERSION/build modules"|' \
            "$dkms_src/dkms.conf"
    fi

    # Register, build and install
    info "Registering module with DKMS..."
    dkms add -m "$MODULE" -v "$VERSION"

    info "Building module (this may take 1-3 minutes)..."
    if $IS_CACHYOS; then
        CC=clang LD=ld.lld dkms build -m "$MODULE" -v "$VERSION"
    else
        dkms build -m "$MODULE" -v "$VERSION"
    fi

    info "Installing compiled modules..."
    dkms install -m "$MODULE" -v "$VERSION"

    success "DKMS installation complete. Modules will auto-recompile on kernel updates."
}

# ── Load modules now (without reboot) ────────────────────────
load_modules_now() {
    step "Loading modules into running kernel..."

    # Unload any conflicting old versions
    for mod in btusb btmtk mt7921e mt7921_common mt792x_lib mt76_connac_lib mt76; do
        rmmod "$mod" 2>/dev/null || true
    done
    sleep 1

    # WiFi stack
    modprobe cfg80211    2>/dev/null || true
    modprobe mac80211    2>/dev/null || true
    modprobe mt76        2>/dev/null || warn "Failed to load mt76"
    modprobe mt76-connac-lib 2>/dev/null || warn "Failed to load mt76-connac-lib"
    modprobe mt792x-lib  2>/dev/null || warn "Failed to load mt792x-lib"
    modprobe mt7921-common 2>/dev/null || warn "Failed to load mt7921-common"
    modprobe mt7921e     2>/dev/null || warn "Failed to load mt7921e"

    # Bluetooth stack
    modprobe bluetooth   2>/dev/null || true
    modprobe btrtl       2>/dev/null || true
    modprobe btintel     2>/dev/null || true
    modprobe btbcm       2>/dev/null || true
    modprobe btmtk       2>/dev/null || warn "Failed to load btmtk"
    modprobe btusb       2>/dev/null || warn "Failed to load btusb"

    # Re-apply regulatory domain
    if [[ -n "${COUNTRY_CODE:-}" ]] && command -v iw &>/dev/null; then
        sleep 1
        iw reg set "$COUNTRY_CODE" 2>/dev/null || true
    fi

    # Restart bluetooth service
    if systemctl is-active --quiet bluetooth; then
        systemctl restart bluetooth 2>/dev/null || true
    fi

    success "Modules loaded."
}

# ── Post-install verification ─────────────────────────────────
verify_install() {
    step "Verifying installation..."
    local ok=true

    echo ""
    info "── DKMS status ──────────────────────────────"
    dkms status | grep mt7902 || warn "mt7902-wifi not found in DKMS status"

    echo ""
    info "── Loaded WiFi modules ──────────────────────"
    lsmod | grep -E 'mt76|mt7921|mt792x' || warn "No mt76 modules loaded"

    echo ""
    info "── Loaded Bluetooth modules ─────────────────"
    lsmod | grep -E 'btusb|btmtk' || warn "No patched BT modules loaded"

    echo ""
    info "── Network interfaces ───────────────────────"
    if command -v ip &>/dev/null; then
        ip link show | grep -E 'wl|wlan' || warn "No WiFi interface found"
    fi

    echo ""
    info "── Regulatory domain ────────────────────────"
    if command -v iw &>/dev/null; then
        iw reg get 2>/dev/null | head -3
    fi

    echo ""
    info "── Firmware check ───────────────────────────"
    ls /lib/firmware/mediatek/WIFI_RAM_CODE_MT7902*.bin* 2>/dev/null \
        && success "WiFi firmware: OK" || warn "WiFi firmware not found"
    ls /lib/firmware/mediatek/BT_RAM_CODE_MT7902*.bin* 2>/dev/null \
        && success "BT firmware: OK" || warn "BT firmware not found"

    echo ""
    if $ok; then
        success "Installation looks good! 🎉"
    else
        warn "Some checks failed. Check dmesg for details: sudo dmesg | grep -i mt79"
    fi
}

# ════════════════════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║   MT7902 WiFi & Bluetooth — Installer v2.0  ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════╝${RESET}"
echo ""

detect_distro
info "Detected: $DISTRO_NAME (kernel: $(uname -r))"
$IS_CACHYOS && info "CachyOS detected — will use Clang compiler"

# Handle --uninstall early (after distro detection)
$UNINSTALL && do_uninstall

echo ""
info "This script will:"
echo "   1. Install build tools and DKMS"
echo "   2. Configure WiFi regulatory domain (country code)"
echo "   3. Handle Bluetooth firmware conflicts"
echo "   4. Build & install driver via DKMS (auto-survives kernel updates)"
echo "   5. Load modules immediately (no reboot needed)"
echo "   6. Verify everything is working"
echo ""
read -rp "Continue? [Y/n]: " confirm
[[ "${confirm,,}" == "n" ]] && { info "Aborted."; exit 0; }

install_deps
configure_regdom
handle_bt_firmware
install_dkms
load_modules_now
verify_install

echo ""
echo -e "${BOLD}${GREEN}════════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}  ✅ MT7902 setup complete!${RESET}"
echo -e "${BOLD}${GREEN}  WiFi + Bluetooth should be working now.${RESET}"
if [[ -n "${COUNTRY_CODE:-}" ]]; then
echo -e "${BOLD}${GREEN}  Regulatory domain: $COUNTRY_CODE${RESET}"
fi
echo -e "${BOLD}${GREEN}════════════════════════════════════════════${RESET}"
echo ""
echo "  📌 If you update your kernel, DKMS handles recompilation automatically."
echo "  📌 To uninstall: sudo bash fix_my_wifi.sh --uninstall"
echo "  📌 To check logs: sudo dmesg | grep -i mt79"
echo ""
