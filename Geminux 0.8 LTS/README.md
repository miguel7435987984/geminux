# Geminux OS 0.8 LTS

**Base:** Ubuntu 24.04 LTS (Noble Numbat)  
**Desenvolvedor:** Geminux OS Team / Geminux Ltda. (Miguel)  
**Status:** Estruturado e Isolado  

---

## 💎 Identidade e Características do Geminux 0.8 LTS
- **Versão:** 0.8 LTS
- **Codinome Base:** Ubuntu 24.04 LTS (Noble Numbat)
- **Tema:** Dark / Neon Geminux (Adwaita-dark / Yaru-blue)
- **Boot Splash:** Plymouth BGRT Spinner oficial do Geminux
- **Barra de Tarefas (Taskbar):** Prius Terminal padrão nos favoritos, Geminux VM, Geminux Store e Nautilus.
- **Áudio:** PipeWire & WirePlumber nativos de baixa latência.
- **Instalador:** Calamares Installer integrado e acessível direto da área de trabalho e dock.

---

## 📁 Estrutura de Diretórios
```
Geminux 0.8 LTS/
├── apps/                   # Aplicativos nativos e lançadores oficiais
├── branding/
│   ├── os-release          # Identidade do SO (Geminux 0.8 LTS Noble)
│   ├── lsb-release         # Metadados de distribuição
│   ├── plymouth/           # Temas de boot splash e spinner
│   └── wallpaper/          # Papéis de parede oficiais
├── config/
│   ├── packages.list       # Lista de pacotes oficiais
│   ├── sources.list.d/     # Repositórios oficiais do Ubuntu 24.04 LTS
│   └── gsettings/          # Override do GNOME com Prius Terminal padrão
├── installer/
│   └── calamares/          # Configuração, temas e branding do Calamares
├── build/
│   ├── build-iso.sh        # Compilador autônomo da ISO (com -all-root e SUID)
│   └── customize.sh        # Hook do chroot para injeção de identidade
└── README.md
```

---

## 🔒 Regras de Preservação e Segurança
1. **Preservação Total do Geminux 1.0 LTS:** Este diretório opera de forma 100% autônoma, sem alterar arquivos, branches ou tags do Geminux 1.0 LTS no GitHub.
2. **Proteção do Sistema Hospedeiro:** Nenhuma modificação em discos físicos (`/dev/sda`), partição de boot ou no `/tmp` do sistema hospedeiro.
