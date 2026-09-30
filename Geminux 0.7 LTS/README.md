# Geminux OS 0.7 LTS

**Base:** Ubuntu 23.04 (Lunar Lobster)  
**Desenvolvedor:** Geminux OS Team / Geminux Ltda. (Miguel)  
**Status:** Estruturado e Isolado  

---

## 💎 Identidade e Características do Geminux 0.7 LTS
- **Versão:** 0.7 LTS
- **Codinome Base:** Ubuntu 23.04 (Lunar Lobster)
- **Kernel Base:** Linux 6.2
- **Ambiente Desktop:** GNOME 44 Minimal
- **Tema:** Dark / Neon Geminux (Adwaita-dark / Yaru-blue)
- **Boot Splash:** Plymouth BGRT Spinner oficial do Geminux
- **Barra de Tarefas (Taskbar):** Prius Terminal padrão nos favoritos, Geminux VM, Geminux Store e Nautilus.
- **Áudio:** PipeWire & WirePlumber nativos de baixa latência.
- **Instalador:** Calamares Installer integrado e acessível direto da área de trabalho e dock.

---

## 📁 Estrutura de Diretórios
```
Geminux 0.7 LTS/
├── apps/                   # Aplicativos nativos e lançadores oficiais (Prius Terminal, Store, VM)
├── branding/
│   ├── os-release          # Identidade do SO (Geminux 0.7 LTS Lunar)
│   ├── lsb-release         # Metadados de distribuição
│   ├── issue               # Mensagem de login no terminal
│   ├── plymouth/           # Temas de boot splash e spinner
│   ├── icons/              # Logotipos e ícones do sistema
│   └── wallpaper/          # Papéis de parede oficiais
├── config/
│   ├── packages.list       # Lista de pacotes oficiais para base Lunar
│   ├── sources.list.d/     # Repositórios oficiais do Ubuntu 23.04 Lunar (old-releases)
│   ├── appstream/          # Metadados de catálogo de apps
│   ├── fastfetch/          # Configuração de informações de sistema
│   └── gsettings/          # Override do GNOME com Prius Terminal padrão na barra
├── installer/
│   └── calamares/          # Configuração, temas e branding do Calamares para 0.7
├── build/
│   ├── build-iso.sh        # Compilador autônomo da ISO (com -all-root e SUID)
│   └── customize.sh        # Hook do chroot para injeção de identidade
└── README.md
```

---

## 🔒 Regras de Preservação e Segurança
1. **Preservação Total do Geminux 1.0 LTS, 0.9 LTS e 0.8 LTS:** Este diretório opera de forma 100% autônoma, sem alterar arquivos, branches ou tags existentes.
2. **Proteção do Sistema Hospedeiro:** Nenhuma modificação em discos físicos (`/dev/sda`), partição de boot ou no `/tmp` do sistema hospedeiro.
