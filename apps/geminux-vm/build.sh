#!/usr/bin/env bash
# ==============================================================================
# Build Debian Package for Geminux Virtual Machine (Geminux OS)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_NAME="geminux-virtual-machine"
VERSION="1.0.0"
ARCH="all"
BUILD_DIR="${SCRIPT_DIR}/build_deb/${PKG_NAME}_${VERSION}_${ARCH}"

echo "==> Building ${PKG_NAME} ${VERSION} Debian package..."

mkdir -p "${BUILD_DIR}/DEBIAN"
mkdir -p "${BUILD_DIR}/usr/bin"
mkdir -p "${BUILD_DIR}/usr/share/applications"
mkdir -p "${BUILD_DIR}/usr/share/metainfo"
mkdir -p "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps"
mkdir -p "${BUILD_DIR}/usr/share/icons/hicolor/256x256/apps"
mkdir -p "${BUILD_DIR}/usr/share/pixmaps"

# Executable, Desktop Entry & Metainfo
install -m 755 "${SCRIPT_DIR}/geminux-vm" "${BUILD_DIR}/usr/bin/geminux-vm"
install -m 644 "${SCRIPT_DIR}/geminux-virtual-machine.desktop" "${BUILD_DIR}/usr/share/applications/geminux-virtual-machine.desktop"
install -m 644 "${SCRIPT_DIR}/geminux-virtual-machine.metainfo.xml" "${BUILD_DIR}/usr/share/metainfo/geminux-virtual-machine.metainfo.xml"

# Branding Icons
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
if [ -f "${ROOT_DIR}/branding/icons/geminux-vm.svg" ]; then
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-vm.svg" "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps/geminux-vm.svg"
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-vm.svg" "${BUILD_DIR}/usr/share/pixmaps/geminux-vm.svg"
fi
if [ -f "${ROOT_DIR}/branding/icons/geminux-vm.png" ]; then
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-vm.png" "${BUILD_DIR}/usr/share/icons/hicolor/256x256/apps/geminux-vm.png"
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-vm.png" "${BUILD_DIR}/usr/share/pixmaps/geminux-vm.png"
fi

# Control File
cat <<EOF > "${BUILD_DIR}/DEBIAN/control"
Package: ${PKG_NAME}
Version: ${VERSION}
Section: admin
Priority: optional
Architecture: ${ARCH}
Maintainer: Geminux OS Team <https://github.com/miguel7435987984/geminux>
Depends: python3, python3-gi, gir1.2-gtk-3.0, gir1.2-gdkpixbuf-2.0, qemu-system-x86, qemu-system-gui, qemu-utils
Recommends: ovmf
Description: Gerenciador oficial de máquinas virtuais para Geminux OS
 O Geminux Virtual Machine é um gerenciador gráfico moderno que permite
 criar e executar máquinas virtuais de Windows, Linux e macOS com
 suporte aos motores KVM / Hyper-V (.qcow2), VirtualBox (.vdi) e VMware (.vmdk).
EOF

# Build DEB package
dpkg-deb --root-owner-group --build "${BUILD_DIR}" "${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
echo "==> Package built successfully at ${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
