#!/usr/bin/env bash
# ==============================================================================
# Build Debian Package for Geminux Custom ROM Creator (Geminux OS)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKG_NAME="geminux-rom-creator"
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
install -m 755 "${SCRIPT_DIR}/geminux-rom-creator" "${BUILD_DIR}/usr/bin/geminux-rom-creator"
install -m 644 "${SCRIPT_DIR}/geminux-rom-creator.desktop" "${BUILD_DIR}/usr/share/applications/geminux-rom-creator.desktop"
install -m 644 "${SCRIPT_DIR}/geminux-rom-creator.metainfo.xml" "${BUILD_DIR}/usr/share/metainfo/geminux-rom-creator.metainfo.xml"

# Branding Icons
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
if [ -f "${ROOT_DIR}/branding/icons/geminux-rom-creator.svg" ]; then
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-rom-creator.svg" "${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps/geminux-rom-creator.svg"
    install -m 644 "${ROOT_DIR}/branding/icons/geminux-rom-creator.svg" "${BUILD_DIR}/usr/share/pixmaps/geminux-rom-creator.svg"
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
Description: Criador e Construtor Oficial de Custom ROMs do Geminux OS
 O Geminux Custom ROM Creator permite que qualquer usuário monte sua própria
 distribuição derivada do Geminux OS, selecionando pacotes, presets gamer ou
 desenvolvedor, temas visuais, otimizações de kernel e compilando imagens ISO.
EOF

# Build DEB package
dpkg-deb --root-owner-group --build "${BUILD_DIR}" "${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
echo "==> Package built successfully at ${SCRIPT_DIR}/${PKG_NAME}_${VERSION}_${ARCH}.deb"
