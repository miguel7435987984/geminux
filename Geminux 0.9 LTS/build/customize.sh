#!/usr/bin/env bash
# ==============================================================================
# Geminux OS 0.9 LTS (Ubuntu 25.10 Kanguru) - Live Customization Hook
# Executado dentro do chroot para aplicar a identidade do Geminux 0.9 LTS
# ==============================================================================

set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> [Geminux 0.9 LTS Hook] Configurando Sistema..."

# 1. Hostname, Hosts & Locales
echo "geminux" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1   localhost
127.0.1.1   geminux
::1         localhost ip6-localhost ip6-loopback
EOF

if [ -x "$(command -v locale-gen)" ]; then
    locale-gen pt_BR.UTF-8 en_US.UTF-8 || true
    update-locale LANG=pt_BR.UTF-8 LC_MESSAGES=POSIX || true
fi

# Timezone America/Sao_Paulo
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
echo "America/Sao_Paulo" > /etc/timezone

# 2. Identidade do SO: Geminux 0.9 LTS
if [ -f /tmp/geminux-build/branding/os-release ]; then
    mkdir -p /etc/geminux
    cp /tmp/geminux-build/branding/os-release /etc/geminux/os-release
    cp /tmp/geminux-build/branding/lsb-release /etc/lsb-release 2>/dev/null || true
    cp /tmp/geminux-build/branding/issue /etc/issue 2>/dev/null || true
    cp /tmp/geminux-build/branding/issue /etc/issue.net 2>/dev/null || true

    # Protege com dpkg-divert para não ser sobrescrito pelo base-files do Ubuntu
    if [ -x "$(command -v dpkg-divert)" ]; then
        dpkg-divert --package geminux-branding --divert /usr/lib/os-release.ubuntu --rename /usr/lib/os-release || true
        dpkg-divert --package geminux-branding --divert /etc/os-release.ubuntu --rename /etc/os-release || true
    fi

    cp /etc/geminux/os-release /usr/lib/os-release
    cp /etc/geminux/os-release /etc/os-release
fi

# 3. Wallpapers & Ícones do Sistema
mkdir -p /usr/share/backgrounds/geminux /usr/share/pixmaps /usr/share/icons/hicolor/scalable/apps /usr/share/icons/hicolor/256x256/apps
if [ -d /tmp/geminux-build/branding/wallpaper ]; then
    cp -r /tmp/geminux-build/branding/wallpaper/* /usr/share/backgrounds/geminux/ 2>/dev/null || true
    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/warty-final-ubuntu.png 2>/dev/null || true
fi
if [ -d /tmp/geminux-build/branding/icons ]; then
    cp /tmp/geminux-build/branding/icons/*.svg /usr/share/icons/hicolor/scalable/apps/ 2>/dev/null || true
    cp /tmp/geminux-build/branding/icons/*.png /usr/share/icons/hicolor/256x256/apps/ 2>/dev/null || true
    cp /tmp/geminux-build/branding/icons/prius-terminal.* /usr/share/pixmaps/ 2>/dev/null || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.* /usr/share/pixmaps/ 2>/dev/null || true
fi

# 4. GSettings Overrides (Tema escuro + Prius Terminal padrão na barra)
if [ -f /tmp/geminux-build/config/gsettings/99_geminux_0.9.gschema.override ]; then
    mkdir -p /usr/share/glib-2.0/schemas
    cp /tmp/geminux-build/config/gsettings/99_geminux_0.9.gschema.override /usr/share/glib-2.0/schemas/
    glib-compile-schemas /usr/share/glib-2.0/schemas/ || true
    echo "    ✓ GSettings override compilado (Prius Terminal na barra de tarefas)"
fi

# 5. Configuração de Repositórios do Ubuntu 25.10 (Kanguru / Questing)
if [ -f /tmp/geminux-build/config/sources.list.d/ubuntu.sources ]; then
    mkdir -p /etc/apt/sources.list.d
    cp /tmp/geminux-build/config/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources
fi

# 6. Plymouth Boot Splash Theme (Official BGRT + 60-frame Boot Spinner)
echo "==> Configurando Plymouth Boot Splash (BGRT + 60-frame Spinner)..."
mkdir -p /etc/plymouth
cat <<'EOF_PLY' > /etc/plymouth/plymouthd.conf
[Daemon]
Theme=bgrt
ShowDelay=0
DeviceTimeout=8
EOF_PLY

mkdir -p /usr/share/plymouth/themes/bgrt
mkdir -p /usr/share/plymouth/themes/spinner

if [ -d /tmp/geminux-build/branding/plymouth/bgrt ]; then
    cp -r /tmp/geminux-build/branding/plymouth/bgrt/* /usr/share/plymouth/themes/bgrt/ || true
fi
if [ -d /tmp/geminux-build/branding/plymouth/spinner ]; then
    cp -r /tmp/geminux-build/branding/plymouth/spinner/* /usr/share/plymouth/themes/spinner/ || true
fi
if [ -f /tmp/geminux-build/branding/icons/geminux-logo.png ]; then
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png || true
fi

if [ -f /usr/share/plymouth/themes/bgrt/bgrt.plymouth ]; then
    if [ -x "$(command -v update-alternatives)" ]; then
        update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/bgrt/bgrt.plymouth 150 || true
        update-alternatives --set default.plymouth /usr/share/plymouth/themes/bgrt/bgrt.plymouth || true
    fi
    if [ -x "$(command -v plymouth-set-default-theme)" ]; then
        plymouth-set-default-theme bgrt || true
    fi
fi

echo "==> [Geminux 0.9 LTS Hook] Finalizado com sucesso!"
