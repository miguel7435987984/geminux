# Geminux OS 0.9 LTS

**Base:** Ubuntu 25.10 (Kanguru)  
**Desenvolvedor:** Geminux OS Team / Geminux Ltda. (Miguel)  
**Status:** Estruturado e Isolado  

---

## 💎 Identidade e Características do Geminux 0.9 LTS
- **Versão:** 0.9 LTS
- **Codinome Base:** Ubuntu 25.10 (Kanguru)
- **Tema:** Dark / Neon Geminux (Adwaita-dark / Yaru-blue)
- **Boot Splash:** Plymouth Crisp Spinner 25.10 de alta definição (sem borrão)
- **Barra de Tarefas (Taskbar):** Prius Terminal padrão nos favoritos, Geminux VM, Geminux Store e Nautilus.
- **Áudio:** PipeWire & WirePlumber nativos de última geração.

---

## 📁 Estrutura de Diretórios
```
Geminux 0.9 LTS/
├── branding/
│   ├── os-release          # Identidade do SO (Geminux 0.9 LTS Kanguru)
│   ├── lsb-release         # Metadados de distribuição
│   └── issue / issue.net   # Banner de terminal
├── config/
│   ├── packages.list       # Lista de pacotes oficiais
│   ├── sources.list.d/     # Repositórios oficiais do Ubuntu 25.10
│   └── gsettings/          # Override do GNOME com Prius Terminal
├── build/
│   ├── build-iso.sh        # Compilador autônomo da ISO
│   └── customize.sh        # Hook do chroot para injeção de identidade
└── README.md
```

---

## 🔒 Regras de Preservação e Segurança
1. **Preservação Total do Geminux 1.0 LTS:** Este diretório opera de forma 100% autônoma, sem alterar arquivos, branches ou tags do Geminux 1.0 LTS no GitHub.
2. **Proteção do Sistema Hospedeiro:** Nenhuma modificação em discos físicos (`/dev/sda`), partição de boot ou no `/tmp` do sistema hospedeiro.
