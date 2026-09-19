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

# 6. Instalação e Montagem dos Aplicativos Nativos do Geminux 0.9 LTS
echo "==> Instalando e configurando os aplicativos nativos do Geminux 0.9 LTS..."

# 6.1 Prius Terminal (Terminal Padrão Oficial do Geminux)
if [ -d /tmp/geminux-build/apps/prius-terminal ]; then
    echo "    -> Instalando Prius Terminal..."
    install -d /usr/local/bin /usr/bin /usr/share/applications /usr/share/icons/hicolor/scalable/apps /usr/share/pixmaps
    install -m 755 /tmp/geminux-build/apps/prius-terminal/prius /usr/local/bin/prius
    install -m 755 /tmp/geminux-build/apps/prius-terminal/prius /usr/bin/prius
    install -m 644 /tmp/geminux-build/apps/prius-terminal/prius-terminal.desktop /usr/share/applications/prius-terminal.desktop
    if [ -f /tmp/geminux-build/branding/icons/prius-terminal.svg ]; then
        install -m 644 /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/icons/hicolor/scalable/apps/prius-terminal.svg
        install -m 644 /tmp/geminux-build/branding/icons/prius-terminal.svg /usr/share/pixmaps/prius-terminal.svg
    fi
fi

# 6.2 Repositório APT Local Oficial do Geminux & Catálogo AppStream
echo "==> Configurando Repositório APT Local e Catálogo AppStream..."
mkdir -p /var/lib/geminux/repo
mkdir -p /usr/share/swcatalog/xml /var/lib/swcatalog/xml /usr/share/app-info/xmls /var/lib/app-info/xmls /usr/share/metainfo

if [ -f /tmp/geminux-build/config/appstream/catalogs/geminux.xml ]; then
    cp /tmp/geminux-build/config/appstream/catalogs/geminux.xml /usr/share/swcatalog/xml/geminux.xml
    cp /tmp/geminux-build/config/appstream/catalogs/geminux.xml /var/lib/swcatalog/xml/geminux.xml
    cp /tmp/geminux-build/config/appstream/catalogs/geminux.xml /usr/share/app-info/xmls/geminux.xml
    cp /tmp/geminux-build/config/appstream/catalogs/geminux.xml /var/lib/app-info/xmls/geminux.xml
fi

if [ -d /tmp/geminux-build/config/appstream/metainfo ]; then
    cp /tmp/geminux-build/config/appstream/metainfo/*.metainfo.xml /usr/share/metainfo/ 2>/dev/null || true
fi

# Copiar todos os pacotes .deb para o repositório local
find /tmp/geminux-build/apps -name "*.deb" -exec cp {} /var/lib/geminux/repo/ \; 2>/dev/null || true

(
    cd /var/lib/geminux/repo
    if [ -x "$(command -v dpkg-scanpackages)" ]; then
        dpkg-scanpackages . /dev/null > Packages 2>/dev/null || true
    fi
    if [ ! -s Packages ]; then
        > Packages
        for deb in *.deb; do
            if [ -f "$deb" ]; then
                dpkg-deb -I "$deb" control 2>/dev/null | sed '/^$/d' >> Packages
                echo "Filename: ./$deb" >> Packages
                echo "Size: $(stat -c%s "$deb")" >> Packages
                echo "SHA256: $(sha256sum "$deb" | cut -d' ' -f1)" >> Packages
                echo "" >> Packages
            fi
        done
    fi
    gzip -9c Packages > Packages.gz

    cat <<'EOF_REL' > Release
Archive: questing
Origin: Geminux
Label: Geminux OS 0.9 LTS
Suite: questing
Codename: questing
Architectures: all amd64
Components: main
Description: Geminux OS 0.9 LTS Official Local Repository
EOF_REL
)

cat <<'EOF_SRC' > /etc/apt/sources.list.d/geminux.list
deb [trusted=yes] file:/var/lib/geminux/repo ./
EOF_SRC

# 6.3 Instalação dos Pacotes e Utilitários Nativos (.deb e lançadores)

# Geminux Terminal
if [ -f /tmp/geminux-build/apps/geminux-terminal/geminux-terminal_1.0.0_all.deb ]; then
    echo "    -> Instalando Geminux Terminal (.deb)..."
    dpkg -i /tmp/geminux-build/apps/geminux-terminal/geminux-terminal_1.0.0_all.deb || apt-get install -f -y
    if [ -x "$(command -v update-alternatives)" ]; then
        update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/geminux-terminal 80 || true
        update-alternatives --set x-terminal-emulator /usr/bin/geminux-terminal || true
    fi
fi

# Sober Fix
if [ -f /tmp/geminux-build/apps/sober-fix/sober-fix_1.0.0_all.deb ]; then
    echo "    -> Instalando Sober Fix (.deb)..."
    dpkg -i /tmp/geminux-build/apps/sober-fix/sober-fix_1.0.0_all.deb || apt-get install -f -y
    ln -sf /usr/bin/sober-fix /usr/local/bin/sober-fix 2>/dev/null || true
elif [ -f /tmp/geminux-build/apps/sober-fix/sober-fix ]; then
    install -d /usr/bin /usr/local/bin /usr/share/metainfo /usr/share/applications
    install -m 755 /tmp/geminux-build/apps/sober-fix/sober-fix /usr/bin/sober-fix
    ln -sf /usr/bin/sober-fix /usr/local/bin/sober-fix 2>/dev/null || true
    if [ -f /tmp/geminux-build/apps/sober-fix/sober-fix.desktop ]; then
        install -m 644 /tmp/geminux-build/apps/sober-fix/sober-fix.desktop /usr/share/applications/sober-fix.desktop
    fi
    if [ -f /tmp/geminux-build/apps/sober-fix/sober-fix.metainfo.xml ]; then
        install -m 644 /tmp/geminux-build/apps/sober-fix/sober-fix.metainfo.xml /usr/share/metainfo/sober-fix.metainfo.xml
    fi
fi

# Geminux Virtual Machine
if [ -f /tmp/geminux-build/apps/geminux-vm/geminux-virtual-machine_1.0.0_all.deb ]; then
    echo "    -> Instalando Geminux Virtual Machine (.deb)..."
    dpkg -i /tmp/geminux-build/apps/geminux-vm/geminux-virtual-machine_1.0.0_all.deb || apt-get install -f -y
    ln -sf /usr/bin/geminux-vm /usr/local/bin/geminux-vm 2>/dev/null || true
    ln -sf /usr/share/applications/geminux-virtual-machine.desktop /usr/share/applications/geminux-vm.desktop 2>/dev/null || true
elif [ -f /tmp/geminux-build/apps/geminux-vm/geminux-vm ]; then
    install -d /usr/bin /usr/local/bin /usr/share/metainfo /usr/share/applications
    install -m 755 /tmp/geminux-build/apps/geminux-vm/geminux-vm /usr/bin/geminux-vm
    ln -sf /usr/bin/geminux-vm /usr/local/bin/geminux-vm 2>/dev/null || true
    if [ -f /tmp/geminux-build/apps/geminux-vm/geminux-virtual-machine.desktop ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-vm/geminux-virtual-machine.desktop /usr/share/applications/geminux-virtual-machine.desktop
        ln -sf /usr/share/applications/geminux-virtual-machine.desktop /usr/share/applications/geminux-vm.desktop 2>/dev/null || true
    fi
    if [ -f /tmp/geminux-build/apps/geminux-vm/geminux-virtual-machine.metainfo.xml ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-vm/geminux-virtual-machine.metainfo.xml /usr/share/metainfo/geminux-virtual-machine.metainfo.xml
    fi
fi

# Geminux AI
if [ -f /tmp/geminux-build/apps/geminux-ai/geminux-ai_1.0.0_all.deb ]; then
    echo "    -> Instalando Geminux AI (.deb)..."
    dpkg -i /tmp/geminux-build/apps/geminux-ai/geminux-ai_1.0.0_all.deb || apt-get install -f -y
    ln -sf /usr/bin/geminux-ai /usr/local/bin/geminux-ai 2>/dev/null || true
elif [ -f /tmp/geminux-build/apps/geminux-ai/geminux-ai ]; then
    install -d /usr/bin /usr/local/bin /usr/share/metainfo /usr/share/applications
    install -m 755 /tmp/geminux-build/apps/geminux-ai/geminux-ai /usr/bin/geminux-ai
    ln -sf /usr/bin/geminux-ai /usr/local/bin/geminux-ai 2>/dev/null || true
    if [ -f /tmp/geminux-build/apps/geminux-ai/geminux-ai.desktop ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-ai/geminux-ai.desktop /usr/share/applications/geminux-ai.desktop
    fi
    if [ -f /tmp/geminux-build/apps/geminux-ai/geminux-ai.metainfo.xml ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-ai/geminux-ai.metainfo.xml /usr/share/metainfo/geminux-ai.metainfo.xml
    fi
fi

# Geminux Welcome
if [ -f /tmp/geminux-build/apps/geminux-welcome/geminux-welcome_1.0.0_all.deb ]; then
    echo "    -> Instalando Geminux Welcome (.deb)..."
    dpkg -i /tmp/geminux-build/apps/geminux-welcome/geminux-welcome_1.0.0_all.deb || apt-get install -f -y
    ln -sf /usr/bin/geminux-welcome /usr/local/bin/geminux-welcome 2>/dev/null || true
elif [ -f /tmp/geminux-build/apps/geminux-welcome/geminux-welcome ]; then
    install -d /usr/bin /usr/local/bin /usr/share/metainfo /usr/share/applications /etc/xdg/autostart
    install -m 755 /tmp/geminux-build/apps/geminux-welcome/geminux-welcome /usr/bin/geminux-welcome
    ln -sf /usr/bin/geminux-welcome /usr/local/bin/geminux-welcome 2>/dev/null || true
    if [ -f /tmp/geminux-build/apps/geminux-welcome/geminux-welcome.desktop ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-welcome/geminux-welcome.desktop /usr/share/applications/geminux-welcome.desktop
        install -m 644 /tmp/geminux-build/apps/geminux-welcome/geminux-welcome.desktop /etc/xdg/autostart/geminux-welcome.desktop
    fi
    if [ -f /tmp/geminux-build/apps/geminux-welcome/geminux-welcome.metainfo.xml ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-welcome/geminux-welcome.metainfo.xml /usr/share/metainfo/geminux-welcome.metainfo.xml
    fi
fi

# Geminux Store
if [ -f /tmp/geminux-build/apps/geminux-store/geminux-store_1.0.0_all.deb ]; then
    echo "    -> Instalando Geminux Store (.deb)..."
    dpkg -i /tmp/geminux-build/apps/geminux-store/geminux-store_1.0.0_all.deb || apt-get install -f -y
    ln -sf /usr/bin/geminux-store /usr/local/bin/geminux-store 2>/dev/null || true
elif [ -f /tmp/geminux-build/apps/geminux-store/geminux-store ]; then
    install -d /usr/bin /usr/local/bin /usr/share/metainfo /usr/share/applications
    install -m 755 /tmp/geminux-build/apps/geminux-store/geminux-store /usr/bin/geminux-store
    ln -sf /usr/bin/geminux-store /usr/local/bin/geminux-store 2>/dev/null || true
    if [ -f /tmp/geminux-build/apps/geminux-store/geminux-store.desktop ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-store/geminux-store.desktop /usr/share/applications/geminux-store.desktop
    fi
    if [ -f /tmp/geminux-build/apps/geminux-store/geminux-store.metainfo.xml ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-store/geminux-store.metainfo.xml /usr/share/metainfo/geminux-store.metainfo.xml
    fi
fi

# Geminux ROM Creator
if [ -f /tmp/geminux-build/apps/geminux-rom-creator/geminux-rom-creator_1.0.0_all.deb ]; then
    echo "    -> Instalando Geminux ROM Creator (.deb)..."
    dpkg -i /tmp/geminux-build/apps/geminux-rom-creator/geminux-rom-creator_1.0.0_all.deb || apt-get install -f -y
    ln -sf /usr/bin/geminux-rom-creator /usr/local/bin/geminux-rom-creator 2>/dev/null || true
elif [ -f /tmp/geminux-build/apps/geminux-rom-creator/geminux-rom-creator ]; then
    install -d /usr/bin /usr/local/bin /usr/share/metainfo /usr/share/applications
    install -m 755 /tmp/geminux-build/apps/geminux-rom-creator/geminux-rom-creator /usr/bin/geminux-rom-creator
    ln -sf /usr/bin/geminux-rom-creator /usr/local/bin/geminux-rom-creator 2>/dev/null || true
    if [ -f /tmp/geminux-build/apps/geminux-rom-creator/geminux-rom-creator.desktop ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-rom-creator/geminux-rom-creator.desktop /usr/share/applications/geminux-rom-creator.desktop
    fi
    if [ -f /tmp/geminux-build/apps/geminux-rom-creator/geminux-rom-creator.metainfo.xml ]; then
        install -m 644 /tmp/geminux-build/apps/geminux-rom-creator/geminux-rom-creator.metainfo.xml /usr/share/metainfo/geminux-rom-creator.metainfo.xml
    fi
fi

# VMware Launcher
if [ -d /tmp/geminux-build/apps/vmware-installer ]; then
    install -d /usr/local/bin /usr/share/metainfo /usr/share/applications
    if [ -f /tmp/geminux-build/apps/vmware-installer/vmware-launcher ]; then
        install -m 755 /tmp/geminux-build/apps/vmware-installer/vmware-launcher /usr/local/bin/vmware-launcher
    fi
    if [ -f /tmp/geminux-build/apps/vmware-installer/vmware.desktop ]; then
        install -m 644 /tmp/geminux-build/apps/vmware-installer/vmware.desktop /usr/share/applications/vmware.desktop
    fi
    if [ -f /tmp/geminux-build/apps/vmware-installer/vmware.metainfo.xml ]; then
        install -m 644 /tmp/geminux-build/apps/vmware-installer/vmware.metainfo.xml /usr/share/metainfo/vmware.metainfo.xml
    fi
fi

# 6.4 Configuração do Fastfetch & Logotipo Oficial do Geminux
echo "==> Configurando Fastfetch com logotipo oficial do Geminux OS..."
mkdir -p /etc/fastfetch /etc/xdg/fastfetch /etc/skel/.config/fastfetch
if [ -d /tmp/geminux-build/config/fastfetch ]; then
    cp /tmp/geminux-build/config/fastfetch/* /etc/fastfetch/ || true
    cp /tmp/geminux-build/config/fastfetch/* /etc/xdg/fastfetch/ || true
    cp /tmp/geminux-build/config/fastfetch/* /etc/skel/.config/fastfetch/ || true
fi

# Assegura que os aliases do fastfetch carreguem o tema oficial do Geminux
cat <<'EOF_BASHRC' >> /etc/bash.bashrc

# Geminux OS Official Fastfetch Configuration
alias fastfetch='fastfetch -c /etc/fastfetch/config.jsonc'
alias neofetch='fastfetch -c /etc/fastfetch/config.jsonc'
alias geminux-info='fastfetch -c /etc/fastfetch/config.jsonc'
EOF_BASHRC

# 6.5 Instalador Oficial do Geminux OS (Calamares)
echo "==> Configurando Instalador Oficial do Geminux (Calamares)..."
mkdir -p /etc/calamares/branding/geminux /etc/calamares/modules
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

# Polkit policies para execução do instalador sem pedir senha de root no Live CD
mkdir -p /usr/share/polkit-1/actions
cat <<'EOF_POLKIT_CALA' > /usr/share/polkit-1/actions/com.github.calamares.calamares.policy
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
EOF_POLKIT_CALA

cat <<'EOF_POLKIT_GEM' > /usr/share/polkit-1/actions/org.geminux.installer.policy
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
EOF_POLKIT_GEM

# Regra sudoers para usuário live executar instalador
mkdir -p /etc/sudoers.d
echo "ALL ALL=(ALL) NOPASSWD: /usr/bin/calamares, /usr/local/bin/geminux-installer" > /etc/sudoers.d/99-geminux-installer
chmod 440 /etc/sudoers.d/99-geminux-installer

# Atalho do Calamares no menu e na área de trabalho
mkdir -p /usr/share/applications /etc/skel/Desktop
cat <<'EOF_DESK_CALA' > /usr/share/applications/calamares.desktop
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
EOF_DESK_CALA
chmod 644 /usr/share/applications/calamares.desktop
cp /usr/share/applications/calamares.desktop /etc/skel/Desktop/calamares.desktop
chmod +x /etc/skel/Desktop/calamares.desktop || true

# Atualizar caches do sistema
if [ -x "$(command -v update-desktop-database)" ]; then
    update-desktop-database /usr/share/applications || true
fi
if [ -x "$(command -v gtk-update-icon-cache)" ]; then
    gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
fi

# 7. Plymouth Boot Splash Theme (Official Geminux BGRT + 60-frame Cyan Boot Spinner)
echo "==> Configurando Plymouth Boot Splash (Geminux BGRT + 60-frame Spinner)..."
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

# Assegura a presenca do logotipo oficial e do watermark Geminux OS
if [ -f /tmp/geminux-build/branding/plymouth/spinner/bgrt-fallback.png ]; then
    cp /tmp/geminux-build/branding/plymouth/spinner/bgrt-fallback.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png
    cp /tmp/geminux-build/branding/plymouth/spinner/bgrt-fallback.png /usr/share/plymouth/themes/bgrt/bgrt-fallback.png 2>/dev/null || true
fi
if [ -f /tmp/geminux-build/branding/plymouth/spinner/watermark.png ]; then
    cp /tmp/geminux-build/branding/plymouth/spinner/watermark.png /usr/share/plymouth/themes/spinner/watermark.png
    cp /tmp/geminux-build/branding/plymouth/spinner/watermark.png /usr/share/plymouth/themes/bgrt/watermark.png 2>/dev/null || true
fi
if [ -f /tmp/geminux-build/branding/icons/geminux-logo.png ]; then
    cp /tmp/geminux-build/branding/icons/geminux-logo.png /usr/share/plymouth/ubuntu-logo.png 2>/dev/null || true
fi

# Atualiza tema de texto do Plymouth (caso de fallback de terminal)
if [ -d /usr/share/plymouth/themes/ubuntu-text ]; then
    sed -i 's/title=Ubuntu.*/title=Geminux OS 0.9 LTS/g' /usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth 2>/dev/null || true
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

# Atualiza obrigatoriamente o initramfs dentro do chroot para gravar o splash do Geminux no boot inicial
echo "==> Atualizando initramfs com os temas oficiais do Geminux 0.9 LTS..."
if [ -x "$(command -v update-initramfs)" ]; then
    update-initramfs -u -k all || true
fi

echo "==> [Geminux 0.9 LTS Hook] Finalizado com sucesso!"
