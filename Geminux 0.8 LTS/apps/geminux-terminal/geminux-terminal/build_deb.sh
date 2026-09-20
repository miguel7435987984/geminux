#!/usr/bin/env bash
set -e

VERSION="1.0.0"
PACKAGE_NAME="geminux-terminal"
ARCH="all"
BUILD_DIR="build_deb"
PKG_DIR="${BUILD_DIR}/${PACKAGE_NAME}_${VERSION}_${ARCH}"

echo "==> Limpando builds anteriores..."
rm -rf "${BUILD_DIR}"
mkdir -p "${PKG_DIR}"

echo "==> Criando estrutura de diretórios para o pacote .deb..."
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/usr/bin"
mkdir -p "${PKG_DIR}/usr/lib/geminux-terminal/src"
mkdir -p "${PKG_DIR}/usr/share/geminux-terminal/themes"
mkdir -p "${PKG_DIR}/usr/share/applications"
mkdir -p "${PKG_DIR}/usr/share/icons/hicolor/scalable/apps"
mkdir -p "${PKG_DIR}/usr/share/doc/geminux-terminal"

echo "==> Copiando arquivos fonte..."
cp src/*.py "${PKG_DIR}/usr/lib/geminux-terminal/src/"
cp data/themes/presets.ini "${PKG_DIR}/usr/share/geminux-terminal/themes/"
cp data/geminux-terminal "${PKG_DIR}/usr/bin/"
chmod 755 "${PKG_DIR}/usr/bin/geminux-terminal"

cp data/geminux-terminal.desktop "${PKG_DIR}/usr/share/applications/"
cp data/icons/geminux-terminal.svg "${PKG_DIR}/usr/share/icons/hicolor/scalable/apps/"

echo "==> Criando arquivo de controle Debian..."
cat << 'EOF' > "${PKG_DIR}/DEBIAN/control"
Package: geminux-terminal
Version: 1.0.0
Section: utils
Priority: optional
Architecture: all
Maintainer: Geminux Project <support@geminux.org>
Depends: python3, python3-gi, gir1.2-gtk-3.0, gir1.2-vte-2.91, python3-cairo
Description: Terminal moderno, bonito e customizável para Linux
 Geminux Terminal é um emulador de terminal elegante com suporte a temas
 modernos (Catppuccin, Dracula, Tokyo Night, Nord, Cyberpunk), transparência
 com efeito glassmorphism, abas, divisão de tela (split panes), pesquisa,
 URLs clicáveis e atalhos customizáveis.
EOF

echo "==> Criando scripts postinst e postrm..."
cat << 'EOF' > "${PKG_DIR}/DEBIAN/postinst"
#!/bin/sh
set -e
if [ "$1" = "configure" ]; then
    if which update-desktop-database >/dev/null 2>&1; then
        update-desktop-database -q /usr/share/applications || true
    fi
    if which gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
    fi
fi
exit 0
EOF
chmod 755 "${PKG_DIR}/DEBIAN/postinst"

cat << 'EOF' > "${PKG_DIR}/DEBIAN/postrm"
#!/bin/sh
set -e
if [ "$1" = "remove" ] || [ "$1" = "purge" ]; then
    if which update-desktop-database >/dev/null 2>&1; then
        update-desktop-database -q /usr/share/applications || true
    fi
    if which gtk-update-icon-cache >/dev/null 2>&1; then
        gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
    fi
fi
exit 0
EOF
chmod 755 "${PKG_DIR}/DEBIAN/postrm"

cat << 'EOF' > "${PKG_DIR}/usr/share/doc/geminux-terminal/README.Debian"
Geminux Terminal para Debian / Ubuntu / Mint / Pop!_OS
======================================================
Para executar, abra o menu de aplicativos ou execute:
  $ geminux-terminal

Atalhos principais:
  Ctrl+Shift+T : Nova Aba
  Ctrl+Shift+W : Fechar Aba/Divisão
  Ctrl+Shift+E : Dividir Verticalmente
  Ctrl+Shift+O : Dividir Horizontalmente
  Ctrl+Shift+F : Buscar no histórico
  Ctrl+Shift+P : Abrir Preferências e Temas
  F11          : Tela Cheia
EOF

echo "==> Compilando pacote .deb..."
dpkg-deb --build --root-owner-group "${PKG_DIR}" "geminux-terminal_1.0.0_all.deb"

echo "==> Pacote gerado com sucesso: geminux-terminal_1.0.0_all.deb"
ls -lh geminux-terminal_1.0.0_all.deb
