#!/usr/bin/env bash
# ==============================================================================
# Geminux Live Customization Hook
# Executed inside the chroot environment to configure Geminux
# ==============================================================================

set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> [Geminux Hook] Configuring System..."

# 1. Hostname, Hosts & Locales Generation
echo "geminux" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1   localhost
127.0.1.1   geminux
::1         localhost ip6-localhost ip6-loopback
EOF

# Pre-generate locales and set America/Sao_Paulo timezone
if [ -x "$(command -v locale-gen)" ]; then
    locale-gen pt_BR.UTF-8 pt_PT.UTF-8 en_US.UTF-8 es_ES.UTF-8 || true
    update-locale LANG=pt_BR.UTF-8 LC_MESSAGES=POSIX || true
fi

# Set default timezone to America/Sao_Paulo (UTC-3)
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
echo "America/Sao_Paulo" > /etc/timezone

# 2. OS Release Information
if [ -f /tmp/geminux-build/branding/os-release ]; then
    cp /tmp/geminux-build/branding/os-release /etc/os-release
    cp /tmp/geminux-build/branding/os-release /usr/lib/os-release
fi

# 3. Wallpapers, Pixmaps & System Branding (GNOME Settings About Page)
mkdir -p /usr/share/backgrounds/geminux
mkdir -p /usr/share/backgrounds
mkdir -p /usr/share/pixmaps
mkdir -p /usr/share/icons/hicolor/scalable/apps
mkdir -p /usr/share/icons/hicolor/256x256/apps
mkdir -p /usr/share/icons/hicolor/128x128/apps
mkdir -p /usr/share/icons/Yaru/scalable/places
mkdir -p /usr/share/icons/Yaru/256x256/places

if [ -d /tmp/geminux-build/branding ]; then
    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/geminux/geminux-default.png
    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/warty-final-ubuntu.png || true
    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/ubuntu-default-greyscale-wallpaper.png || true

    # System App Icons
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/icons/hicolor/scalable/apps/
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/icons/hicolor/256x256/apps/
    cp /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/icons/hicolor/scalable/apps/
    cp /tmp/geminux-build/branding/icons/prius-terminal.png /usr/share/icons/hicolor/128x128/apps/

    # GNOME Settings (About Page) & GDM Login Screen Pixmaps & Logos
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/pixmaps/ubuntu-logo.svg || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/pixmaps/ubuntu-logo-text.svg || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/pixmaps/ubuntu-logo-text-dark.svg || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/pixmaps/ubuntu-logo-text.png || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/pixmaps/ubuntu-logo-text-dark.png || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/icons/gnome-logo-text.svg || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/icons/gnome-logo-text-dark.svg || true

    # GDM Greeter Vendor Logos
    mkdir -p /usr/share/images/vendor-logos
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/images/vendor-logos/logo-text-version-64.png || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/images/vendor-logos/logo-text-version-128.png || true

    # Distributor Logo (Yaru Theme)
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/icons/Yaru/scalable/places/distributor-logo-symbolic.svg || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/icons/Yaru/256x256/places/distributor-logo.png || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/icons/Yaru/256x256@2x/places/distributor-logo.png || true
fi

# 4. Install Prius Terminal & Geminux Terminal
if [ -d /tmp/geminux-build/apps/prius-terminal ]; then
    install -d /usr/local/bin
    install -d /usr/share/applications
    install -d /usr/share/icons/hicolor/scalable/apps

    install -m 755 /tmp/geminux-build/apps/prius-terminal/prius /usr/local/bin/prius
    install -m 644 /tmp/geminux-build/apps/prius-terminal/prius-terminal.desktop /usr/share/applications/prius-terminal.desktop
    install -m 644 /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/icons/hicolor/scalable/apps/prius-terminal.svg
fi

# Install Geminux Terminal (.deb) as default system terminal (replacing gnome-terminal)
if [ -f /tmp/geminux-build/apps/geminux-terminal/geminux-terminal_1.0.0_all.deb ]; then
    dpkg -i /tmp/geminux-build/apps/geminux-terminal/geminux-terminal_1.0.0_all.deb || apt-get install -f -y
    if [ -x "$(command -v update-alternatives)" ]; then
        update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/geminux-terminal 80 || true
        update-alternatives --set x-terminal-emulator /usr/bin/geminux-terminal || true
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

# 7. Native Mozilla Firefox Installation & Enterprise Policies
echo "==> Installing Native Mozilla Firefox (.deb)..."
install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

cat << 'SOURCES' > /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
SOURCES

cat << 'PREF' > /etc/apt/preferences.d/mozilla
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
PREF

apt-get update
apt-get install -y firefox firefox-l10n-pt-br

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
mkdir -p /etc/calamares/modules
if [ -d /tmp/geminux-build/installer/calamares ]; then
    cp /tmp/geminux-build/installer/calamares/settings.conf /etc/calamares/settings.conf || true
    cp -r /tmp/geminux-build/installer/calamares/branding/geminux/* /etc/calamares/branding/geminux/ || true
    if [ -d /tmp/geminux-build/installer/calamares/modules ]; then
        cp -r /tmp/geminux-build/installer/calamares/modules/* /etc/calamares/modules/ || true
    fi
    if [ -f /tmp/geminux-build/installer/calamares/geminux-installer ]; then
        install -m 755 /tmp/geminux-build/installer/calamares/geminux-installer /usr/local/bin/geminux-installer
    fi
fi

# Ensure Calamares and wrapper have Polkit execution without password
cat <<'EOF' > /usr/share/polkit-1/actions/com.github.calamares.calamares.policy
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>
  <action id="com.github.calamares.calamares">
    <description>Run Calamares Installer</description>
    <message>Authentication is required to install Geminux</message>
    <defaults>
      <allow_any>yes</allow_any>
      <allow_inactive>yes</allow_inactive>
      <allow_active>yes</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/usr/bin/calamares</annotate>
    <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
  </action>
</policyconfig>
EOF

cat <<'EOF' > /usr/share/polkit-1/actions/org.geminux.installer.policy
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>
  <action id="org.geminux.installer">
    <description>Run Geminux Installer</description>
    <message>Authentication is required to run installer</message>
    <defaults>
      <allow_any>yes</allow_any>
      <allow_inactive>yes</allow_inactive>
      <allow_active>yes</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/usr/local/bin/geminux-installer</annotate>
    <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
  </action>
</policyconfig>
EOF

# Sudoers rule for live user to run calamares without password
mkdir -p /etc/sudoers.d
echo "ALL ALL=(ALL) NOPASSWD: /usr/bin/calamares, /usr/local/bin/geminux-installer" > /etc/sudoers.d/99-geminux-installer
chmod 440 /etc/sudoers.d/99-geminux-installer

# Launcher for Calamares on Desktop
cat <<'EOF' > /usr/share/applications/calamares.desktop
[Desktop Entry]
Type=Application
Version=1.0
Name=Install Geminux OS
GenericName=Live Installer
Comment=Install the operating system to disk
Exec=/usr/local/bin/geminux-installer
Icon=calamares
Terminal=false
Categories=System;Qt;
StartupNotify=true
EOF
chmod 644 /usr/share/applications/calamares.desktop

# 10. Fastfetch Configuration & Custom Logo
mkdir -p /etc/fastfetch
if [ -d /tmp/geminux-build/config/fastfetch ]; then
    cp /tmp/geminux-build/config/fastfetch/* /etc/fastfetch/ || true
fi

# 11. Custom App Names: Geminux Atualizações (Update Manager) & Central de Aplicativos
if [ -f /usr/share/applications/update-manager.desktop ]; then
    sed -i 's/^Name=.*/Name=Geminux Atualizações/g' /usr/share/applications/update-manager.desktop || true
    sed -i 's/^Name\[pt_BR\]=.*/Name[pt_BR]=Geminux Atualizações/g' /usr/share/applications/update-manager.desktop || true
    sed -i 's/^GenericName=.*/GenericName=Geminux Atualizações/g' /usr/share/applications/update-manager.desktop || true
    sed -i 's/^GenericName\[pt_BR\]=.*/GenericName[pt_BR]=Geminux Atualizações/g' /usr/share/applications/update-manager.desktop || true
fi

# 12. User Skel Configuration
if [ -f /tmp/geminux-build/config/skel/home/.bashrc_geminux ]; then
    cat /tmp/geminux-build/config/skel/home/.bashrc_geminux >> /etc/skel/.bashrc
fi

# 12. Generate initramfs for Live boot
KERNEL_VER=$(ls -1 /lib/modules | tail -n 1)
if [ -n "${KERNEL_VER}" ]; then
    echo "==> Generating initramfs for kernel ${KERNEL_VER}..."
    update-initramfs -c -k "${KERNEL_VER}" || update-initramfs -u -k all || true
fi

echo "==> [Geminux Hook] Customization completed successfully!"
