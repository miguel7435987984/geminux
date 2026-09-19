# 🚀 Geminux Terminal

Um emulador de terminal moderno, bonito, rápido e altamente customizável para distribuições Linux (Debian, Ubuntu, Linux Mint, Pop!_OS, etc.).

---

## ✨ Funcionalidades Principais

* 🎨 **Temas Integrados Elegantes**:
  * *Catppuccin Mocha*
  * *Dracula*
  * *Tokyo Night*
  * *Nord*
  * *One Dark Pro*
  * *Cyberpunk Neon*
  * *Solarized Dark*
  * *Gruvbox Dark*
  * *Monokai Pro*
  * *Rose Pine*
* 🔮 **Transparência & Efeito Glassmorphism** com controle deslizante de opacidade em tempo real.
* 📑 **Múltiplas Abas** com suporte a fechar, reordenar e títulos dinâmicos.
* 🪟 **Divisão de Tela (Split Panes)**: Divida a janela horizontal e verticalmente para trabalhar em múltiplos shells lado a lado.
* 🔍 **Pesquisa Integrada**: Pesquise histórico de comandos e logs facilmente (`Ctrl+Shift+F`).
* 🔗 **Links & URLs Clicáveis**: `Ctrl + Clique` abre URLs diretamente no seu navegador padrão.
* 🎛️ **Painel Completo de Preferências Gráficas**:
  * Seletor de fontes com suporte a tamanhos, famílias e negrito.
  * Formatos de cursor: Bloco, I-Beam (barra vertical) ou Underline (sublinhado).
  * Controle de piscar do cursor e alarme sonoro.
  * Editor de paleta ANSI de 16 cores e fundo/texto customizados.
* 📦 **Pacote Debian (.deb) pronto para instalação**.

---

## ⌨️ Atalhos de Teclado

| Atalho | Ação |
|---|---|
| `Ctrl + Shift + T` | Nova Aba |
| `Ctrl + Shift + W` | Fechar Aba / Divisão Atual |
| `Ctrl + Shift + E` | Dividir Terminal Verticalmente |
| `Ctrl + Shift + O` | Dividir Terminal Horizontalmente |
| `Ctrl + Shift + C` | Copiar Seleção |
| `Ctrl + Shift + V` | Colar da Área de Transferência |
| `Ctrl + Shift + F` | Abrir Barra de Pesquisa |
| `Ctrl + Shift + P` | Abrir Preferências & Cores |
| `Ctrl + Tab` / `Ctrl + PageDown` | Próxima Aba |
| `Ctrl + Shift + Tab` / `Ctrl + PageUp` | Aba Anterior |
| `Ctrl + +` / `Ctrl + -` | Aumentar / Diminuir Zoom |
| `Ctrl + 0` | Resetar Zoom da Fonte |
| `F11` | Alternar Modo Tela Cheia |
| `Ctrl + Clique` | Abrir Link / URL no Navegador |

---

## 📥 Como Instalar o Pacote `.deb`

Para instalar no seu sistema, execute no terminal:

```bash
sudo apt install ./geminux-terminal_1.0.0_all.deb
```

Ou usando `dpkg`:

```bash
sudo dpkg -i geminux-terminal_1.0.0_all.deb
sudo apt install -f # para garantir quaisquer dependências pendentes
```

Após instalar, você pode abrir digitando `geminux-terminal` ou pelo menu de aplicativos do seu sistema!

---

## 🛠️ Como Compilar / Reconstruir o Pacote `.deb`

Caso você faça alterações no código-fonte em `geminux-terminal/src/`:

```bash
cd geminux-terminal
./build_deb.sh
```
