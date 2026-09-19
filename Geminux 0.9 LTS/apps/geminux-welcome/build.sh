#!/usr/bin/env bash
# ==============================================================================
# Build Debian Package for Geminux Welcome (Geminux OS)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_NAME="geminux-welcome"
VERSION="1.0.0"
ARCH="all"
BUILD_DIR="${SCRIPT_DIR}/build_deb/${PKG_NAME}_${VERSION}_${ARCH}"

echo "==> Building ${PKG_NAME} ${VERSION} Debian package..."

mkdir -p "${BUILD_DIR}/DEBIAN"
mkdir -p "${BUILD_DIR}/usr/bin"
mkdir -p "${BUILD_DIR}/usr/share/applications"
mkdir -p "${BUILD_DIR}/usr/share/metainfo"
mkdir -p "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps"
mkdir -p "${BUILD_DIR}/usr/share/pixmaps"
mkdir -p "${BUILD_DIR}/etc/xdg/autostart"

# Executable, Desktop Entry & Metainfo
install -m 755 "${SCRIPT_DIR}/geminux-welcome" "${BUILD_DIR}/usr/bin/geminux-welcome"
install -m 644 "${SCRIPT_DIR}/geminux-welcome.desktop" "${BUILD_DIR}/usr/share/applications/geminux-welcome.desktop"
install -m 644 "${SCRIPT_DIR}/geminux-welcome.desktop" "${BUILD_DIR}/etc/xdg/autostart/geminux-welcome.desktop"
install -m 644 "${SCRIPT_DIR}/geminux-welcome.metainfo.xml" "${BUILD_DIR}/usr/share/metainfo/geminux-welcome.metainfo.xml"

# Branding Icons
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
if [ -f "${ROOT_DIR}/branding/icons/geminux-welcome.svg" ]; then
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-welcome.svg" "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps/geminux-welcome.svg"
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-welcome.svg" "${BUILD_DIR}/usr/share/pixmaps/geminux-welcome.svg"
fi

# Control File
cat <<EOF > "${BUILD_DIR}/DEBIAN/control"
Package: ${PKG_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: Geminux OS Team <https://github.com/miguel7435987984/geminux>
Depends: python3, python3-gi, gir1.2-gtk-3.0
Description: Centro de Boas-Vindas e Tour Oficial do Geminux OS
 O Geminux Welcome apresenta os pilares fundamentais do Geminux OS:
 Geminux AI, Geminux Virtual Machine, Prius Terminal, Geminux Store
 e opções rápidas de personalização e configurações do sistema.
EOF

# Build DEB package
dpkg-deb --root-owner-group --build "${BUILD_DIR}" "${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
echo "==> Package built successfully at ${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
