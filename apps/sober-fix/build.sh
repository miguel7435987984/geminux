#!/usr/bin/env bash
# ==============================================================================
# Build Debian Package for Sober Fix (Geminux OS)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_NAME="sober-fix"
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

# Binaries & Desktop & Metainfo
install -m 755 "${SCRIPT_DIR}/sober-fix" "${BUILD_DIR}/usr/bin/sober-fix"
install -m 644 "${SCRIPT_DIR}/sober-fix.desktop" "${BUILD_DIR}/usr/share/applications/sober-fix.desktop"
install -m 644 "${SCRIPT_DIR}/sober-fix.metainfo.xml" "${BUILD_DIR}/usr/share/metainfo/sober-fix.metainfo.xml"

# Branding Icons
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
if [ -f "${ROOT_DIR}/branding/icons/sober-fix.svg" ]; then
    install -m 644 "${ROOT_DIR}/branding/icons/sober-fix.svg" "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps/sober-fix.svg"
    install -m 644 "${ROOT_DIR}/branding/icons/sober-fix.svg" "${BUILD_DIR}/usr/share/pixmaps/sober-fix.svg"
fi

# Control File
cat <<EOF > "${BUILD_DIR}/DEBIAN/control"
Package: ${PKG_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: Geminux OS Team <support@geminux.org>
Depends: bash, flatpak
Description: Utilitário oficial de limpeza e reparo do Sober (Roblox) no Geminux OS
 O Sober Fix é um utilitário exclusivo desenvolvido para o Geminux OS que
 resolve travamentos, erros de atualização e problemas de cache do cliente
 Sober / Roblox no Linux.
EOF

# Build DEB
dpkg-deb --root-owner-group --build "${BUILD_DIR}" "${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
echo "==> Package built successfully at ${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
