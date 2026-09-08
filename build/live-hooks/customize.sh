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

# 2. OS Release Information (Protected with dpkg-divert)
if [ -f /tmp/geminux-build/branding/os-release ]; then
    mkdir -p /etc/geminux
    cp /tmp/geminux-build/branding/os-release /etc/geminux/os-release

    # Use dpkg-divert so base-files upgrades never overwrite Geminux OS identity
    if [ -x "$(command -v dpkg-divert)" ]; then
        dpkg-divert --package geminux-branding --divert /usr/lib/os-release.ubuntu --rename /usr/lib/os-release || true
        dpkg-divert --package geminux-branding --divert /etc/os-release.ubuntu --rename /etc/os-release || true
    fi

    cp /etc/geminux/os-release /usr/lib/os-release
    cp /etc/geminux/os-release /etc/os-release
fi

# 3. Wallpapers, Pixmaps & System Branding (GNOME Settings About Page & GDM Login Screen)
mkdir -p /usr/share/backgrounds/geminux
mkdir -p /usr/share/backgrounds
mkdir -p /usr/share/pixmaps
mkdir -p /usr/share/icons/hicolor/scalable/apps
mkdir -p /usr/share/icons/hicolor/256x256/apps
mkdir -p /usr/share/icons/hicolor/128x128/apps
mkdir -p /usr/share/icons/Yaru/scalable/places
mkdir -p /usr/share/icons/Yaru/256x256/places
mkdir -p /etc/geminux/branding

if [ -d /tmp/geminux-build/branding ]; then
    cp -r /tmp/geminux-build/branding/* /etc/geminux/branding/ || true

    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/geminux/geminux-default.png
    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/warty-final-ubuntu.png || true
    cp /tmp/geminux-build/branding/wallpaper/geminux-default.png /usr/share/backgrounds/ubuntu-default-greyscale-wallpaper.png || true

    # System App Icons
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/icons/hicolor/scalable/apps/
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/icons/hicolor/256x256/apps/
    cp /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/icons/hicolor/scalable/apps/
    cp /tmp/geminux-build/branding/icons/prius-terminal.png /usr/share/icons/hicolor/128x128/apps/
    cp /tmp/geminux-build/branding/icons/vmware.svg /usr/share/icons/hicolor/scalable/apps/ || true
    cp /tmp/geminux-build/branding/icons/sober-fix.svg /usr/share/icons/hicolor/scalable/apps/ || true
    cp /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/pixmaps/prius-terminal.svg || true
    cp /tmp/geminux-build/branding/icons/prius-terminal.png /usr/share/pixmaps/prius-terminal.png || true
    cp /tmp/geminux-build/branding/icons/vmware.svg /usr/share/pixmaps/vmware.svg || true
    cp /tmp/geminux-build/branding/icons/sober-fix.svg /usr/share/pixmaps/sober-fix.svg || true
    mkdir -p /usr/share/icons/Yaru/scalable/apps
    cp /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/icons/Yaru/scalable/apps/ || true
    cp /tmp/geminux-build/branding/icons/geminux-logo.svg /usr/share/icons/Yaru/scalable/apps/ || true
    cp /tmp/geminux-build/branding/icons/vmware.svg /usr/share/icons/Yaru/scalable/apps/ || true
    cp /tmp/geminux-build/branding/icons/sober-fix.svg /usr/share/icons/Yaru/scalable/apps/ || true

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

# 4. Install Prius Terminal & Geminux Terminal & sober-fix
if [ -d /tmp/geminux-build/apps/prius-terminal ]; then
    install -d /usr/local/bin
    install -d /usr/share/applications
    install -d /usr/share/icons/hicolor/scalable/apps

    install -m 755 /tmp/geminux-build/apps/prius-terminal/prius /usr/local/bin/prius
    install -m 644 /tmp/geminux-build/apps/prius-terminal/prius-terminal.desktop /usr/share/applications/prius-terminal.desktop
    install -m 644 /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/icons/hicolor/scalable/apps/prius-terminal.svg
fi

# Install sober-fix utility (Roblox / Sober repair tool) & Geminux Store Metainfo
if [ -f /tmp/geminux-build/apps/sober-fix/sober-fix ]; then
    install -d /usr/local/bin
    install -d /usr/share/metainfo
    install -d /usr/share/applications
    install -m 755 /tmp/geminux-build/apps/sober-fix/sober-fix /usr/local/bin/sober-fix
    if [ -f /tmp/geminux-build/apps/sober-fix/sober-fix.desktop ]; then
        install -m 644 /tmp/geminux-build/apps/sober-fix/sober-fix.desktop /usr/share/applications/sober-fix.desktop
    fi
    if [ -f /tmp/geminux-build/apps/sober-fix/sober-fix.metainfo.xml ]; then
        install -m 644 /tmp/geminux-build/apps/sober-fix/sober-fix.metainfo.xml /usr/share/metainfo/sober-fix.metainfo.xml
    fi
fi

# Install VMware Workstation & VirtualBox AppStream Metadata for Geminux Store
if [ -d /tmp/geminux-build/apps/vmware-installer ]; then
    install -d /usr/local/bin
    install -d /usr/share/metainfo
    install -d /usr/share/applications
    install -m 755 /tmp/geminux-build/apps/vmware-installer/vmware-launcher /usr/local/bin/vmware-launcher
    if [ -f /tmp/geminux-build/apps/vmware-installer/vmware.desktop ]; then
        install -m 644 /tmp/geminux-build/apps/vmware-installer/vmware.desktop /usr/share/applications/vmware.desktop
    fi
    if [ -f /tmp/geminux-build/apps/vmware-installer/vmware.metainfo.xml ]; then
        install -m 644 /tmp/geminux-build/apps/vmware-installer/vmware.metainfo.xml /usr/share/metainfo/vmware.metainfo.xml
    fi
fi

# Install VirtualBox AppStream Metadata for Geminux Store
if [ -f /tmp/geminux-build/config/appstream/metainfo/virtualbox.metainfo.xml ]; then
    install -d /usr/share/metainfo
    install -m 644 /tmp/geminux-build/config/appstream/metainfo/virtualbox.metainfo.xml /usr/share/metainfo/virtualbox.metainfo.xml
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

# 8. GNOME GSettings Schema Overrides (Highest Priority 99)
mkdir -p /usr/share/glib-2.0/schemas
if [ -f /tmp/geminux-build/config/gsettings/99_geminux.gschema.override ]; then
    cp /tmp/geminux-build/config/gsettings/99_geminux.gschema.override /usr/share/glib-2.0/schemas/
    glib-compile-schemas /usr/share/glib-2.0/schemas || true
fi

# 8.1 APT Branding Shield Hook (Ensures Geminux themes, Sobre page, Login screen, Store & settings persist through any system upgrade)
mkdir -p /etc/apt/apt.conf.d
cat <<'EOF' > /etc/apt/apt.conf.d/99geminux-branding
DPkg::Post-Invoke {
    "if [ -f /etc/geminux/os-release ]; then cp /etc/geminux/os-release /etc/os-release && cp /etc/geminux/os-release /usr/lib/os-release || true; fi";
    "if [ -d /etc/geminux/branding ]; then cp /etc/geminux/branding/wallpaper/geminux-default.png /usr/share/backgrounds/warty-final-ubuntu.png 2>/dev/null || true; cp /etc/geminux/branding/icons/geminux-logo.svg /usr/share/pixmaps/ubuntu-logo.svg 2>/dev/null || true; cp /etc/geminux/branding/icons/geminux-logo.svg /usr/share/pixmaps/ubuntu-logo-text.svg 2>/dev/null || true; cp /etc/geminux/branding/icons/geminux-logo.png /usr/share/pixmaps/ubuntu-logo-text.png 2>/dev/null || true; cp /etc/geminux/branding/icons/geminux-logo.svg /usr/share/icons/gnome-logo-text.svg 2>/dev/null || true; fi";
    "for app in /usr/share/applications/snap-store_snap-store.desktop /usr/share/applications/snap-store.desktop /usr/share/applications/org.gnome.Software.desktop /usr/share/applications/ubuntu-app-center.desktop /usr/share/applications/app-center.desktop; do if [ -f \"$app\" ]; then sed -i 's/^Name=.*/Name=Geminux Store/g; s/^Name\\[pt_BR\\]=.*/Name[pt_BR]=Geminux Store/g; s/^GenericName=.*/GenericName=Geminux Store/g; s/^GenericName\\[pt_BR\\]=.*/GenericName[pt_BR]=Geminux Store/g' \"$app\" 2>/dev/null || true; fi; done";
    "for task in /usr/share/applications/gnome-system-monitor.desktop /usr/share/applications/org.gnome.SystemMonitor.desktop; do if [ -f \"$task\" ]; then sed -i 's/^Name=.*/Name=Geminux TaskView/g; s/^Name\\[pt_BR\\]=.*/Name[pt_BR]=Geminux TaskView/g; s/^GenericName=.*/GenericName=Geminux TaskView/g; s/^GenericName\\[pt_BR\\]=.*/GenericName[pt_BR]=Geminux TaskView/g' \"$task\" 2>/dev/null || true; fi; done";
    "rm -f /etc/xdg/autostart/update-notifier.desktop /usr/share/applications/update-manager.desktop /etc/apt/apt.conf.d/99update-notifier /etc/apt/apt.conf.d/15update-stamp 2>/dev/null || true";
    "if [ -d /etc/NetworkManager/conf.d ]; then printf '[keyfile]\nunmanaged-devices=none\n' > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf || true; fi";
    "if [ -d /usr/share/glib-2.0/schemas ]; then glib-compile-schemas /usr/share/glib-2.0/schemas || true; fi";
    "if [ -x /usr/bin/gtk-update-icon-cache ]; then gtk-update-icon-cache -q -f -t /usr/share/icons/hicolor /usr/share/icons/Yaru 2>/dev/null || true; fi";
    "if [ -x /usr/bin/update-desktop-database ]; then update-desktop-database -q /usr/share/applications 2>/dev/null || true; fi";
};
EOF

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

# Disable automatic popups and update notifications completely
mkdir -p /etc/apt/apt.conf.d
cat <<'EOF' > /etc/apt/apt.conf.d/99disable-periodic-updates
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF
rm -f /etc/apt/apt.conf.d/99update-notifier || true
rm -f /etc/apt/apt.conf.d/15update-stamp || true

# Neutralize update-notifier and update-manager binaries with dpkg-divert so they never execute
dpkg-divert --divert /usr/bin/update-notifier.real --local --rename /usr/bin/update-notifier 2>/dev/null || true
cat <<'EOF' > /usr/bin/update-notifier
#!/bin/sh
exit 0
EOF
chmod 755 /usr/bin/update-notifier

dpkg-divert --divert /usr/bin/update-manager.real --local --rename /usr/bin/update-manager 2>/dev/null || true
cat <<'EOF' > /usr/bin/update-manager
#!/bin/sh
exit 0
EOF
chmod 755 /usr/bin/update-manager

# Remove update notifier autostart and menu shortcuts
rm -f /etc/xdg/autostart/update-notifier.desktop || true
rm -f /usr/share/applications/update-manager.desktop || true

# Mask all systemd user and system units for update-notifier
mkdir -p /etc/systemd/user /etc/systemd/system
for u in update-notifier.service update-notifier-release.path update-notifier-crash.path update-notifier-livepatch.path update-notifier-motd.timer update-notifier-download.timer update-notifier-motd.service update-notifier-download.service; do
    ln -sf /dev/null "/etc/systemd/user/${u}" 2>/dev/null || true
    ln -sf /dev/null "/etc/systemd/system/${u}" 2>/dev/null || true
done

for app_desktop in /usr/share/applications/snap-store_snap-store.desktop /usr/share/applications/snap-store.desktop /usr/share/applications/org.gnome.Software.desktop /usr/share/applications/ubuntu-app-center.desktop /usr/share/applications/app-center.desktop; do
    if [ -f "$app_desktop" ]; then
        sed -i 's/^Name=.*/Name=Geminux Store/g' "$app_desktop" || true
        sed -i 's/^Name\[pt_BR\]=.*/Name[pt_BR]=Geminux Store/g' "$app_desktop" || true
        sed -i 's/^GenericName=.*/GenericName=Geminux Store/g' "$app_desktop" || true
        sed -i 's/^GenericName\[pt_BR\]=.*/GenericName[pt_BR]=Geminux Store/g' "$app_desktop" || true
    fi
done

for task_desktop in /usr/share/applications/gnome-system-monitor.desktop /usr/share/applications/org.gnome.SystemMonitor.desktop; do
    if [ -f "$task_desktop" ]; then
        sed -i 's/^Name=.*/Name=Geminux TaskView/g' "$task_desktop" || true
        sed -i 's/^Name\[pt_BR\]=.*/Name[pt_BR]=Geminux TaskView/g' "$task_desktop" || true
        sed -i 's/^GenericName=.*/GenericName=Geminux TaskView/g' "$task_desktop" || true
        sed -i 's/^GenericName\[pt_BR\]=.*/GenericName[pt_BR]=Geminux TaskView/g' "$task_desktop" || true
    fi
done

# Configure Flathub Repository & AppStream Metadata Cache for Geminux Store (including Sober / Roblox & Games)
if [ -x "$(command -v flatpak)" ]; then
    echo "==> Configuring Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    echo "==> Updating Flathub AppStream metadata cache..."
    flatpak update --appstream -y || true
fi
if [ -x "$(command -v appstreamcli)" ]; then
    echo "==> Refreshing AppStream catalog cache..."
    appstreamcli refresh-cache --force || true
fi

# 12. User Skel Configuration
if [ -f /tmp/geminux-build/config/skel/home/.bashrc_geminux ]; then
    cat /tmp/geminux-build/config/skel/home/.bashrc_geminux >> /etc/skel/.bashrc
fi

# 13. Network & Wi-Fi Configuration for Notebooks & Desktops (NetworkManager & Netplan)
echo "==> Configuring NetworkManager, Netplan and Wi-Fi drivers..."
mkdir -p /etc/netplan
cat <<'EOF' > /etc/netplan/01-network-manager-all.yaml
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
EOF
chmod 600 /etc/netplan/01-network-manager-all.yaml

# Ensure NetworkManager manages all devices globally (Ethernet, Wi-Fi, WWAN)
mkdir -p /etc/NetworkManager/conf.d
cat <<'EOF' > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
[keyfile]
unmanaged-devices=none
EOF

# NetworkManager base configuration
cat <<'EOF' > /etc/NetworkManager/NetworkManager.conf
[main]
plugins=ifupdown,keyfile
dns=systemd-resolved

[ifupdown]
managed=true

[device]
wifi.scan-rand-mac-address=no
EOF

# Prevent aggressive Wi-Fi powersaving and MAC randomization that drops Wi-Fi handshake on laptop cards
cat <<'EOF' > /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.powersave=2
wifi.cloned-mac-address=preserve
ethernet.cloned-mac-address=preserve
EOF

# Allow unauthenticated NetworkManager actions on Live session & user session (Polkit)
mkdir -p /etc/polkit-1/rules.d
cat <<'EOF' > /etc/polkit-1/rules.d/99-geminux-networkmanager.rules
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0) {
        return polkit.Result.YES;
    }
});
EOF

# Ensure NetworkManager, systemd-resolved, and wpa_supplicant are enabled
if [ -x "$(command -v systemctl)" ]; then
    systemctl enable NetworkManager || true
    systemctl enable systemd-resolved || true
    systemctl enable wpa_supplicant || true
fi

# Enable PAM GNOME Keyring so Wi-Fi passwords unlock smoothly
if [ -x "$(command -v pam-auth-update)" ]; then
    pam-auth-update --package || true
fi

# Run netplan generate if netplan is installed
if [ -x "$(command -v netplan)" ]; then
    netplan generate || true
fi

# Unblock all wireless devices (rfkill unblock all) via systemd service on boot
mkdir -p /etc/systemd/system
cat <<'EOF' > /etc/systemd/system/geminux-rfkill-unblock.service
[Unit]
Description=Unblock all wireless devices on Geminux boot
After=network-pre.target
Before=NetworkManager.service

[Service]
Type=oneshot
ExecStart=/usr/sbin/rfkill unblock all
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

if [ -x "$(command -v systemctl)" ]; then
    systemctl enable geminux-rfkill-unblock.service || true
fi

# Set Brazil (BR) regulatory domain as standard for wireless frequencies
if [ -x "$(command -v iw)" ]; then
    iw reg set BR 2>/dev/null || true
fi
if [ -f /etc/default/crda ]; then
    sed -i 's/^REGDOMAIN=.*/REGDOMAIN=BR/g' /etc/default/crda 2>/dev/null || true
fi

# 14. Update Desktop & Icon Caches
if [ -x "$(command -v update-desktop-database)" ]; then
    update-desktop-database /usr/share/applications || true
fi
if [ -x "$(command -v gtk-update-icon-cache)" ]; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
    gtk-update-icon-cache -f -t /usr/share/icons/Yaru || true
fi

# 15. Generate initramfs for Live boot
KERNEL_VER=$(ls -1 /lib/modules | tail -n 1)
if [ -n "${KERNEL_VER}" ]; then
    echo "==> Generating initramfs for kernel ${KERNEL_VER}..."
    update-initramfs -c -k "${KERNEL_VER}" || update-initramfs -u -k all || true
fi

# Ensure /etc/resolv.conf is properly linked to systemd-resolved stub
rm -f /etc/resolv.conf || true
ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true

echo "==> [Geminux Hook] Customization completed successfully!"
