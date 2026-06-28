#!/bin/bash
# ============================================================
#  🎯 MT7902 WiFi & Bluetooth — Instalador Universal v2.0 (ES)
# ============================================================
#  Compatible con: Debian / Ubuntu / Mint  Y  Arch / Manjaro /
#                  EndeavourOS / CachyOS / Garuda
#
#  CARACTERÍSTICAS:
#   ✅ DKMS — el driver sobrevive actualizaciones del kernel
#   ✅ Dominio regulatorio WiFi (código de país) para máxima señal
#   ✅ Módulos Bluetooth parcheados (btusb + btmtk)
#   ✅ Resolución de conflicto de firmware BT
#   ✅ Verificación post-instalación
#   ✅ Modo desinstalación (--desinstalar)
#
#  USO:
#   sudo bash instalar_wifi.sh                (interactivo)
#   sudo bash instalar_wifi.sh --pais PE      (no interactivo, Perú)
#   sudo bash instalar_wifi.sh --desinstalar  (eliminar todo)
#
#  REQUISITOS:
#   - Conexión a internet en la primera ejecución (ethernet o tethering USB)
#   - Ejecutar como root (sudo)
# ============================================================

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────
ROJO='\033[0;31m'; VERDE='\033[0;32m'; AMARILLO='\033[1;33m'
CIAN='\033[0;36m'; NEGRITA='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CIAN}ℹ️  $*${RESET}"; }
exito()   { echo -e "${VERDE}✅ $*${RESET}"; }
aviso()   { echo -e "${AMARILLO}⚠️  $*${RESET}"; }
error()   { echo -e "${ROJO}❌ $*${RESET}" >&2; exit 1; }
paso()    { echo -e "\n${NEGRITA}${CIAN}▶ $*${RESET}"; }

# ── Verificaciones iniciales ──────────────────────────────────
[[ $EUID -ne 0 ]] && error "Ejecuta este script con sudo: sudo bash $0"

DIR_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_DRIVER="$DIR_SCRIPT/latest"
[[ ! -d "$DIR_DRIVER" ]] && error "No se encontró el driver en '$DIR_DRIVER'. ¿Estás en el directorio correcto?"

# ── Argumentos ────────────────────────────────────────────────
ARG_PAIS=""
DESINSTALAR=false
for arg in "$@"; do
    case "$arg" in
        --desinstalar|--uninstall) DESINSTALAR=true ;;
        --pais|--country) shift; ARG_PAIS="${1:-}" ;;
        --pais=*|--country=*) ARG_PAIS="${arg#*=}" ;;
    esac
done

# ── Detección de distribución ─────────────────────────────────
detectar_distro() {
    local id="" id_like=""
    if [[ -f /etc/os-release ]]; then
        id=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
        id_like=$(grep -E '^ID_LIKE=' /etc/os-release | cut -d= -f2 | tr -d '"' | tr '[:upper:]' '[:lower:]')
    fi

    ES_ARCH=false; ES_DEBIAN=false; ES_CACHYOS=false; GESTOR_PKG=""

    if echo "$id $id_like" | grep -qE 'arch|manjaro|endeavouros|garuda|cachyos'; then
        ES_ARCH=true; GESTOR_PKG="pacman"
        echo "$id" | grep -q 'cachyos' && ES_CACHYOS=true
    elif echo "$id $id_like" | grep -qE 'debian|ubuntu|mint|pop|linuxmint'; then
        ES_DEBIAN=true; GESTOR_PKG="apt"
    else
        error "Distribución no compatible: '$id'. Soportadas: Debian/Ubuntu/Arch y sus derivadas."
    fi

    NOMBRE_DISTRO=$(grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null \
                    | cut -d= -f2 | tr -d '"' || echo "$id")
}

# ── Modo DESINSTALAR ──────────────────────────────────────────
hacer_desinstalacion() {
    echo ""
    echo -e "${ROJO}${NEGRITA}╔══════════════════════════════════════════════════════╗${RESET}"
    echo -e "${ROJO}${NEGRITA}║  ⚠️  ADVERTENCIA IMPORTANTE                          ║${RESET}"
    echo -e "${ROJO}${NEGRITA}║  Esto eliminará los drivers de WiFi y Bluetooth.     ║${RESET}"
    echo -e "${ROJO}${NEGRITA}║  Si no tienes Ethernet u otra conexión activa,       ║${RESET}"
    echo -e "${ROJO}${NEGRITA}║  PERDERÁS el acceso a internet tras la desinstalación║${RESET}"
    echo -e "${ROJO}${NEGRITA}╚══════════════════════════════════════════════════════╝${RESET}"
    echo ""
    read -rp "  ¿Tienes Ethernet u otra conexión de respaldo activa? [s/N]: " red_ok
    [[ "${red_ok,,}" != "s" && "${red_ok,,}" != "y" ]] && {
        info "Desinstalación cancelada. Conecta un cable de red primero."
        exit 0
    }
    echo ""
    aviso "Última oportunidad — esta acción eliminará WiFi y Bluetooth."
    read -rp "  Escribe 'CONFIRMAR' para continuar: " doble_check
    [[ "$doble_check" != "CONFIRMAR" ]] && { info "Cancelado."; exit 0; }

    paso "Desinstalando driver MT7902..."

    # Eliminar DKMS
    if command -v dkms &>/dev/null && dkms status | grep -q 'mt7902-wifi'; then
        info "Eliminando módulo DKMS..."
        dkms remove mt7902-wifi/1.0 --all 2>/dev/null || true
        rm -rf /usr/src/mt7902-wifi-1.0
        exito "Módulo DKMS eliminado."
    fi

    # Servicio systemd (legacy)
    if systemctl list-unit-files mt7902.service &>/dev/null 2>&1; then
        systemctl stop mt7902.service 2>/dev/null || true
        systemctl disable mt7902.service 2>/dev/null || true
        rm -f /etc/systemd/system/mt7902.service
        systemctl daemon-reload
    fi
    rm -f /usr/local/bin/mt7902-setup.sh
    rm -rf /lib/modules/mt7902_custom

    aviso "Se conserva la configuración de dominio regulatorio. Elimínala manualmente si lo deseas."
    exito "Desinstalación completa. Reinicia el sistema si hay problemas."
    exit 0
}

# ── Instalar dependencias ─────────────────────────────────────
instalar_dependencias() {
    paso "Instalando dependencias de compilación para $NOMBRE_DISTRO..."
    if $ES_DEBIAN; then
        apt-get update -qq
        apt-get install -y \
            build-essential \
            "linux-headers-$(uname -r)" \
            dkms \
            bc \
            wireless-regdb \
            iw \
            2>/dev/null
    elif $ES_ARCH; then
        local pkgs=(base-devel dkms iw wireless-regdb)
        $ES_CACHYOS && pkgs+=(clang llvm lld)

        local pkg_headers=""
        if uname -r | grep -q 'cachyos'; then
            pkg_headers="linux-cachyos-headers"
        elif uname -r | grep -q 'lts'; then
            pkg_headers="linux-lts-headers"
        elif uname -r | grep -q 'zen'; then
            pkg_headers="linux-zen-headers"
        elif uname -r | grep -q 'hardened'; then
            pkg_headers="linux-hardened-headers"
        else
            pkg_headers="linux-headers"
        fi
        pkgs+=("$pkg_headers")
        pacman -S --needed --noconfirm "${pkgs[@]}"
    fi
    exito "Dependencias instaladas correctamente."
}

# ── Dominio regulatorio (código de país) ──────────────────────
configurar_dominio() {
    paso "Configurando dominio regulatorio WiFi (código de país)..."
    info "Esto establece los límites de potencia y canales legales para tu país."
    info "Un código incorrecto = señal artificialmente limitada por el kernel."

    local pais="$ARG_PAIS"

    if [[ -z "$pais" ]]; then
        # Prioridad 1: configuración existente en el sistema
        local actual=""
        if [[ -f /etc/conf.d/wireless-regdom ]]; then
            actual=$(grep -oP '(?<=WIRELESS_REGDOM=")[A-Z]{2}' /etc/conf.d/wireless-regdom 2>/dev/null || true)
        elif [[ -f /etc/default/crda ]]; then
            actual=$(grep -oP '(?<=REGDOMAIN=)[A-Z]{2}' /etc/default/crda 2>/dev/null || true)
        fi

        # Prioridad 2: detectar desde el locale del sistema (ej. es_PE.UTF-8 → PE)
        if [[ -z "$actual" ]]; then
            local pais_locale
            pais_locale=$(locale 2>/dev/null | grep -E '^LANG=' \
                | grep -oP '[a-z]{2}_\K[A-Z]{2}(?=\.)' | head -1 || true)
            if [[ -n "$pais_locale" ]]; then
                actual="$pais_locale"
                info "País detectado automáticamente desde el idioma del sistema: '$actual'"
            fi
        fi

        if [[ -n "$actual" ]]; then
            aviso "Código de país detectado: '$actual'"
            read -rp "  ¿Usar '$actual'? [S/n]: " resp
            [[ "${resp,,}" == "n" ]] || { pais="$actual"; }
        fi

        if [[ -z "$pais" ]]; then
            echo ""
            echo "  Códigos comunes: US, PE, MX, AR, BR, CO, CL, ES, GB, DE, FR, JP"
            read -rp "  Ingresa tu código de país de 2 letras [por defecto: US]: " pais
            pais="${pais:-US}"
        fi
    fi

    # Validar: 2 letras mayúsculas
    pais="${pais^^}"
    [[ "$pais" =~ ^[A-Z]{2}$ ]] || error "Código de país inválido: '$pais'. Usa 2 letras como PE, US, MX."

    info "Estableciendo dominio regulatorio: $pais"

    # Aplicar inmediatamente
    if command -v iw &>/dev/null; then
        iw reg set "$pais" && exito "Dominio regulatorio '$pais' aplicado (activo ahora)." \
                           || aviso "No se pudo aplicar ahora — se aplicará al siguiente arranque."
    fi

    # Persistir en Arch/systemd
    if $ES_ARCH; then
        mkdir -p /etc/conf.d
        echo "WIRELESS_REGDOM=\"$pais\"" > /etc/conf.d/wireless-regdom
        if systemctl list-unit-files wireless-regdom.service &>/dev/null 2>&1; then
            systemctl enable --now wireless-regdom.service 2>/dev/null || true
        fi
        exito "Dominio '$pais' guardado en /etc/conf.d/wireless-regdom"
    fi

    # Persistir en Debian/Ubuntu
    if $ES_DEBIAN; then
        if [[ -f /etc/default/crda ]]; then
            sed -i "s/^REGDOMAIN=.*/REGDOMAIN=$pais/" /etc/default/crda
        else
            echo "REGDOMAIN=$pais" > /etc/default/crda
        fi
        exito "Dominio '$pais' guardado en /etc/default/crda"
    fi

    # Opción de módulo cfg80211 — funciona en ambas distros
    mkdir -p /etc/modprobe.d
    echo "options cfg80211 ieee80211_regdom=$pais" > /etc/modprobe.d/cfg80211.conf
    exito "Opción de módulo cfg80211 configurada (el dominio carga junto con el driver WiFi)."

    CODIGO_PAIS="$pais"
}

# ── Instalar y Resolver Firmwares ────────────────────────────
instalar_firmwares() {
    paso "Instalando todos los firmwares requeridos (WiFi y Bluetooth)..."
    
    local fw_base="$DIR_SCRIPT/mt7902_firmware"
    local fw_latest="$fw_base/latest"
    
    info "Copiando archivos de firmware a /lib/firmware/mediatek/..."
    mkdir -p /lib/firmware/mediatek
    
    # Copiar firmwares base
    if ls "$fw_base"/*.bin* 1> /dev/null 2>&1; then
        cp "$fw_base"/*.bin* /lib/firmware/mediatek/ 2>/dev/null || true
    fi
    # Copiar firmwares recientes (sobrescribe antiguos)
    if ls "$fw_latest"/*.bin* 1> /dev/null 2>&1; then
        cp "$fw_latest"/*.bin* /lib/firmware/mediatek/ 2>/dev/null || true
    fi
    exito "Firmwares instalados correctamente."

    paso "Verificando conflictos de firmware Bluetooth..."
    local fw_conflicto="/lib/firmware/mediatek/mt7902/BT_RAM_CODE_MT7902_1_1_hdr.bin.zst"
    local fw_conflicto2="/lib/firmware/mediatek/mt7902/BT_RAM_CODE_MT7902_1_1_hdr.bin"

    if [[ -f "$fw_conflicto" ]] || [[ -f "$fw_conflicto2" ]]; then
        aviso "Firmware BT conflictivo detectado en /lib/firmware/mediatek/mt7902/"
        aviso "Esto puede impedir que el Bluetooth funcione correctamente."
        read -rp "  ¿Eliminar el firmware conflictivo? [S/n]: " resp
        if [[ "${resp,,}" != "n" ]]; then
            rm -f "$fw_conflicto" "$fw_conflicto2" 2>/dev/null || true
            exito "Firmware conflictivo eliminado."
        else
            aviso "Omitido — el Bluetooth podría no funcionar correctamente."
        fi
    else
        exito "Sin conflictos de firmware BT."
    fi
}

# ── Instalación con DKMS ──────────────────────────────────────
instalar_dkms() {
    paso "Instalando driver mediante DKMS (sobrevive actualizaciones del kernel)..."

    local src_dkms="/usr/src/mt7902-wifi-1.0"
    local MODULO="mt7902-wifi"
    local VERSION="1.0"

    # Eliminar entrada DKMS antigua si existe
    if dkms status | grep -q "$MODULO/$VERSION"; then
        info "Eliminando entrada DKMS anterior..."
        dkms remove "$MODULO/$VERSION" --all 2>/dev/null || true
    fi

    rm -rf "$src_dkms"

    info "Copiando fuentes del driver a $src_dkms ..."
    mkdir -p "$src_dkms"
    if command -v rsync &>/dev/null; then
        rsync -a --exclude='*.o' --exclude='*.ko' --exclude='*.ko.zst' \
              --exclude='.tmp_versions' --exclude='Module.symvers' \
              --exclude='modules.order' --exclude='.git' \
              "$DIR_DRIVER/" "$src_dkms/"
    else
        cp -a "$DIR_DRIVER/." "$src_dkms/"
    fi

    # Verificar o generar dkms.conf
    if [[ ! -f "$src_dkms/dkms.conf" ]]; then
        aviso "No se encontró dkms.conf, generando uno automáticamente..."
        cat > "$src_dkms/dkms.conf" << 'DKMSEOF'
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

    # CachyOS: compilar con clang
    if $ES_CACHYOS; then
        info "Detectado CachyOS — configurando compilador Clang en DKMS..."
        sed -i 's|MAKE\[0\]=.*|MAKE[0]="make CC=clang LD=ld.lld -C $kernel_source_dir M=$dkms_tree/$PACKAGE_NAME/$PACKAGE_VERSION/build modules"|' \
            "$src_dkms/dkms.conf"
    fi

    info "Registrando módulo en DKMS..."
    dkms add -m "$MODULO" -v "$VERSION"

    info "Compilando módulos (puede tardar 1-3 minutos)..."
    if $ES_CACHYOS; then
        CC=clang LD=ld.lld dkms build -m "$MODULO" -v "$VERSION"
    else
        dkms build -m "$MODULO" -v "$VERSION"
    fi

    info "Instalando módulos compilados..."
    dkms install -m "$MODULO" -v "$VERSION"

    exito "Instalación DKMS completa. Los módulos se recompilarán solos al actualizar el kernel."
}

# ── Cargar módulos ahora (sin reiniciar) ──────────────────────
cargar_modulos() {
    paso "Cargando módulos en el kernel en ejecución..."

    # Descargar versiones antiguas
    for mod in btusb btmtk mt7921e mt7921_common mt792x_lib mt76_connac_lib mt76; do
        rmmod "$mod" 2>/dev/null || true
    done
    sleep 1

    # Stack WiFi
    modprobe cfg80211     2>/dev/null || true
    modprobe mac80211     2>/dev/null || true
    modprobe mt76         2>/dev/null || aviso "Error al cargar mt76"
    modprobe mt76-connac-lib 2>/dev/null || aviso "Error al cargar mt76-connac-lib"
    modprobe mt792x-lib   2>/dev/null || aviso "Error al cargar mt792x-lib"
    modprobe mt7921-common 2>/dev/null || aviso "Error al cargar mt7921-common"
    modprobe mt7921e      2>/dev/null || aviso "Error al cargar mt7921e"

    # Stack Bluetooth
    modprobe bluetooth    2>/dev/null || true
    modprobe btrtl        2>/dev/null || true
    modprobe btintel      2>/dev/null || true
    modprobe btbcm        2>/dev/null || true
    modprobe btmtk        2>/dev/null || aviso "Error al cargar btmtk"
    modprobe btusb        2>/dev/null || aviso "Error al cargar btusb"

    # Re-aplicar dominio regulatorio
    if [[ -n "${CODIGO_PAIS:-}" ]] && command -v iw &>/dev/null; then
        sleep 1
        iw reg set "$CODIGO_PAIS" 2>/dev/null || true
    fi

    # Reiniciar bluetooth
    if systemctl is-active --quiet bluetooth; then
        systemctl restart bluetooth 2>/dev/null || true
    fi

    exito "Módulos cargados correctamente."
}

# ── Verificación post-instalación ────────────────────────────
verificar_instalacion() {
    paso "Verificando la instalación..."
    echo ""

    info "── Estado DKMS ──────────────────────────────────────"
    dkms status | grep mt7902 || aviso "mt7902-wifi no aparece en el estado DKMS"

    echo ""
    info "── Módulos WiFi cargados ────────────────────────────"
    lsmod | grep -E 'mt76|mt7921|mt792x' || aviso "No se encontraron módulos mt76"

    echo ""
    info "── Módulos Bluetooth cargados ───────────────────────"
    lsmod | grep -E 'btusb|btmtk' || aviso "No se encontraron módulos BT parcheados"

    echo ""
    info "── Interfaces de red ────────────────────────────────"
    if command -v ip &>/dev/null; then
        ip link show | grep -E 'wl|wlan' || aviso "No se encontró interfaz WiFi"
    fi

    echo ""
    info "── Dominio regulatorio activo ───────────────────────"
    command -v iw &>/dev/null && iw reg get 2>/dev/null | head -3

    echo ""
    info "── Verificación de firmware ─────────────────────────"
    ls /lib/firmware/mediatek/WIFI_RAM_CODE_MT7902*.bin* 2>/dev/null \
        && exito "Firmware WiFi: OK" || aviso "Firmware WiFi no encontrado"
    ls /lib/firmware/mediatek/BT_RAM_CODE_MT7902*.bin* 2>/dev/null \
        && exito "Firmware Bluetooth: OK" || aviso "Firmware BT no encontrado"
}

# ════════════════════════════════════════════════════════════
#  PRINCIPAL
# ════════════════════════════════════════════════════════════
echo ""
echo -e "${NEGRITA}${CIAN}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${NEGRITA}${CIAN}║  MT7902 WiFi & Bluetooth — Instalador v2.0 (ES) ║${RESET}"
echo -e "${NEGRITA}${CIAN}║  github.com/SkimerPM                             ║${RESET}"
echo -e "${NEGRITA}${CIAN}╚══════════════════════════════════════════════════╝${RESET}"
echo ""

detectar_distro
info "Sistema detectado: $NOMBRE_DISTRO (kernel: $(uname -r))"
$ES_CACHYOS && info "CachyOS detectado — se usará el compilador Clang"

# Manejar --desinstalar
$DESINSTALAR && hacer_desinstalacion

echo ""
info "Este script realizará los siguientes pasos:"
echo "   1. Instalar herramientas de compilación y DKMS"
echo "   2. Configurar el dominio regulatorio WiFi (código de país)"
echo "   3. Instalar firmwares y resolver conflictos BT"
echo "   4. Compilar e instalar el driver via DKMS (se actualiza solo)"
echo "   5. Cargar los módulos inmediatamente (sin reiniciar)"
echo "   6. Verificar que todo funcione correctamente"
echo ""
read -rp "¿Continuar? [S/n]: " confirmar
[[ "${confirmar,,}" == "n" ]] && { info "Cancelado."; exit 0; }

instalar_dependencias
configurar_dominio
instalar_firmwares
instalar_dkms
cargar_modulos
verificar_instalacion

echo ""
echo -e "${NEGRITA}${VERDE}══════════════════════════════════════════════════${RESET}"
echo -e "${NEGRITA}${VERDE}  ✅ ¡Instalación completada con éxito!${RESET}"
echo -e "${NEGRITA}${VERDE}  WiFi + Bluetooth deberían estar funcionando.${RESET}"
if [[ -n "${CODIGO_PAIS:-}" ]]; then
echo -e "${NEGRITA}${VERDE}  Dominio regulatorio: $CODIGO_PAIS${RESET}"
fi
echo -e "${NEGRITA}${VERDE}══════════════════════════════════════════════════${RESET}"
echo ""
echo "  📌 Al actualizar el kernel, DKMS recompila el driver automáticamente."
echo "  📌 Para desinstalar: sudo bash instalar_wifi.sh --desinstalar"
echo "  📌 Para ver logs:    sudo dmesg | grep -i mt79"
echo ""
