# Geminux OS

<div align="center">
  <img src="branding/icons/geminux-logo.svg" width="140" alt="Geminux OS Logo" />
  <h1>Geminux OS 1.0 LTS</h1>
  <p><strong>A Distribuição Linux Inteligente, Futurista e Leve</strong></p>
</div>

---

## 🌟 Sobre o Geminux
O **Geminux OS** é uma distribuição Linux moderna baseada no **Ubuntu 26.04 LTS (Resolute)**, combinando estabilidade corporativa, o inovador **Prius Terminal**, design escuro nativo no ambiente **GNOME** e o instalador amigável **Calamares**.

## 🚀 Principais Recursos
- **⚡ Prius Terminal:** Terminal nativo desenvolvido em Python 3 + GTK3/VTE com paleta neon ciano (`#00d2ff`), suporte a abas e atalhos rápidos.
- **🌐 Mozilla Firefox Customizado:** Pré-configurado com uBlock Origin, proteção de privacidade e DuckDuckGo.
- **🎨 GNOME Minimal Dark:** Visual escuro (`Adwaita-dark`), ícones `Yaru-blue` e dock com os apps essenciais.
- **💿 Instalador Gráfico Calamares:** Instalação fácil em dual-boot ou substituição total de disco.
- **✨ Plymouth & GRUB:** Animações e menus de boot personalizados com a identidade visual do Geminux.

---

## 📦 Edições Oficiais do Geminux OS

| Versão | Base do Sistema | Status | Download da ISO | Release Oficial no GitHub |
| :--- | :--- | :--- | :--- | :--- |
| **Geminux OS 1.0 LTS** | Ubuntu 26.04 LTS (Resolute) | 🟢 **Principal / Mais Recente** | [Baixar ISO 1.0 (1.9 GB)](https://github.com/miguel7435987984/geminux/releases/download/v1.0/geminux-1.0-amd64.iso) | [Ver Release v1.0](https://github.com/miguel7435987984/geminux/releases/tag/v1.0) |
| **Geminux OS 0.9 LTS** | Ubuntu 25.10 (Kanguru) | 🔵 **Edição Predecessora Estável** | [Baixar ISO 0.9 (1.6 GB)](https://github.com/miguel7435987984/geminux/releases/download/v0.9/geminux-0.9-amd64.iso) | [Ver Release v0.9](https://github.com/miguel7435987984/geminux/releases/tag/v0.9) |

---

### 💎 Geminux OS 0.9 LTS (Ubuntu 25.10 Kanguru)
> **Edição Predecessora Isolada e Independente**  
> Versão clássica baseada no **Ubuntu 25.10 (Kanguru / Questing)**, equipada com o tema Plymouth de boot nítido, logotipo oficial Geminux no Fastfetch, Prius Terminal na dock, repositório APT local e instalador gráfico Calamares.

<div align="center">

[![Download Geminux 0.9](https://img.shields.io/badge/Download_ISO-Geminux_0.9_LTS-00d2ff?style=for-the-badge&logo=linux&logoColor=black)](https://github.com/miguel7435987984/geminux/releases/download/v0.9/geminux-0.9-amd64.iso)
[![GitHub Release v0.9](https://img.shields.io/badge/GitHub-Release_v0.9-238636?style=for-the-badge&logo=github)](https://github.com/miguel7435987984/geminux/releases/tag/v0.9)

</div>

---

## 🛠️ Como Gerar a ISO no GitHub Actions (Nuvem)

Este repositório já conta com **GitHub Actions** configurado para construir a ISO automaticamente nos servidores de alta performance do GitHub:

1. Suba o código para o seu repositório no GitHub:
   ```bash
   git init
   git add .
   git commit -m "feat: initial commit for Geminux OS 1.0"
   git branch -M main
   git remote add origin https://github.com/SEU_USUARIO/geminux.git
   git push -u origin main
   ```

2. Acesse a aba **Actions** no seu GitHub.
3. O workflow **`Build Geminux OS ISO`** iniciará a compilação automática na nuvem.
4. Quando terminar, baixe o arquivo `geminux-1.0-amd64.iso` direto na seção **Releases** ou **Artifacts**!

---

## 🌐 Site Oficial
O projeto inclui uma landing page completa na pasta `website/`.

---
© 2026 Geminux OS Project - Desenvolvido por Miguel.
