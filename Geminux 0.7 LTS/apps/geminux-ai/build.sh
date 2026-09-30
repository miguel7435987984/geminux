#!/usr/bin/env bash
# ==============================================================================
# Build Debian Package for Geminux AI (Geminux OS)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_NAME="geminux-ai"
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

# Executable, Desktop Entry & Metainfo
install -m 755 "${SCRIPT_DIR}/geminux-ai" "${BUILD_DIR}/usr/bin/geminux-ai"
install -m 644 "${SCRIPT_DIR}/geminux-ai.desktop" "${BUILD_DIR}/usr/share/applications/geminux-ai.desktop"
install -m 644 "${SCRIPT_DIR}/geminux-ai.metainfo.xml" "${BUILD_DIR}/usr/share/metainfo/geminux-ai.metainfo.xml"

# Branding Icons
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
if [ -f "${ROOT_DIR}/branding/icons/geminux-ai.svg" ]; then
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-ai.svg" "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps/geminux-ai.svg"
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-ai.svg" "${BUILD_DIR}/usr/share/pixmaps/geminux-ai.svg"
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
Description: Assistente inteligente oficial para Geminux OS
 O Geminux AI é um assistente moderno com inteligência artificial
 desenvolvido para ajudar o usuário com comandos do Linux,
 atalhos do Prius Terminal, diagnósticos do sistema e tarefas diárias.
EOF

# Build DEB package
dpkg-deb --root-owner-group --build "${BUILD_DIR}" "${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
echo "==> Package built successfully at ${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
