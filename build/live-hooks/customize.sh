#!/usr/bin/env bash
# ==============================================================================
# Geminux Live Customization Hook
# Executed inside the chroot environment to configure Geminux
# ==============================================================================

set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> [Geminux Hook] Configuring System..."

# 1. Hostname & Hosts
echo "geminux" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1   localhost
127.0.1.1   geminux
::1         localhost ip6-localhost ip6-loopback
EOF

# 2. OS Release Information
if [ -f /tmp/geminux-build/branding/os-release ]; then
    cp /tmp/geminux-build/branding/os-release /etc/os-release
    cp /tmp/geminux-build/branding/os-release /usr/lib/os-release
fi

# 3. Wallpapers & Icons
mkdir -p /usr/share/backgrounds/geminux
mkdir -p /usr/share/backgrounds
mkdir -p /usr/share/icons/hicolor/scalable/apps
mkdir -p /usr/share/icons/hicolor/256x256/apps
mkdir -p /usr/share/icons/hicolor/128x128/apps

if [ -d /tmp/geminux-build/branding ]; then
    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/geminux/geminux-default.png
    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/warty-final-ubuntu.png || true
    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/ubuntu-default-greyscale-wallpaper.png || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/icons/hicolor/scalable/apps/
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/icons/hicolor/256x256/apps/
    cp /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/icons/hicolor/scalable/apps/
    cp /tmp/geminux-build/branding/icons/prius-terminal.png /usr/share/icons/hicolor/128x128/apps/
fi

# 4. Install Prius Terminal
if [ -d /tmp/geminux-build/apps/prius-terminal ]; then
    install -d /usr/local/bin
    install -d /usr/share/applications
    install -d /usr/share/icons/hicolor/scalable/apps

    install -m 755 /tmp/geminux-build/apps/prius-terminal/prius /usr/local/bin/prius
    install -m 644 /tmp/geminux-build/apps/prius-terminal/prius-terminal.desktop /usr/share/applications/prius-terminal.desktop
    install -m 644 /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/icons/hicolor/scalable/apps/prius-terminal.svg

    if [ -x "$(command -v update-alternatives)" ]; then
        update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/local/bin/prius 60 || true
    fi
fi

# 5. Plymouth Boot Splash Theme
mkdir -p /usr/share/plymouth/themes/geminux-plymouth
if [ -d /tmp/geminux-build/branding/plymouth/geminux-plymouth ]; then
    cp -r /tmp/geminux-build/branding/plymouth/geminux-plymouth/* /usr/share/plymouth/themes/geminux-plymouth/
    if [ -x "$(command -v update-alternatives)" ]; then
        update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/geminux-plymouth/geminux-plymouth.plymouth 100 || true
        update-alternatives --set default.plymouth /usr/share/plymouth/themes/geminux-plymouth/geminux-plymouth.plymouth || true
    fi
fi

# 6. GRUB Theme
mkdir -p /boot/grub/themes/geminux-grub
if [ -d /tmp/geminux-build/branding/grub/geminux-grub ]; then
    cp -r /tmp/geminux-build/branding/grub/geminux-grub/* /boot/grub/themes/geminux-grub/
    echo 'GRUB_THEME="/boot/grub/themes/geminux-grub/theme.txt"' >> /etc/default/grub
fi

# 7. Firefox Enterprise Policy & Defaults
mkdir -p /etc/firefox/policies
if [ -f /tmp/geminux-build/config/firefox/policies.json ]; then
    cp /tmp/geminux-build/config/firefox/policies.json /etc/firefox/policies/policies.json
fi

# 8. GNOME GSettings Schema Overrides
mkdir -p /usr/share/glib-2.0/schemas
if [ -f /tmp/geminux-build/config/gsettings/01_geminux.gschema.override ]; then
    cp /tmp/geminux-build/config/gsettings/01_geminux.gschema.override /usr/share/glib-2.0/schemas/
    glib-compile-schemas /usr/share/glib-2.0/schemas || true
fi

# 9. Calamares Installer Branding & Configuration
mkdir -p /etc/calamares/branding/geminux
if [ -d /tmp/geminux-build/installer/calamares ]; then
    cp /tmp/geminux-build/installer/calamares/settings.conf /etc/calamares/settings.conf || true
    cp -r /tmp/geminux-build/installer/calamares/branding/geminux/* /etc/calamares/branding/geminux/ || true
fi

# 10. User Skel Configuration
if [ -f /tmp/geminux-build/config/skel/home/.bashrc_geminux ]; then
    cat /tmp/geminux-build/config/skel/home/.bashrc_geminux >> /etc/skel/.bashrc
fi

# 11. Generate initramfs for Live boot
KERNEL_VER=$(ls -1 /lib/modules | tail -n 1)
if [ -n "${KERNEL_VER}" ]; then
    echo "==> Generating initramfs for kernel ${KERNEL_VER}..."
    update-initramfs -c -k "${KERNEL_VER}" || update-initramfs -u -k all || true
fi

echo "==> [Geminux Hook] Customization completed successfully!"
