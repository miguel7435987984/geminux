#!/usr/bin/env python3
"""
Render official icon and AppStream screenshot for Geminux Virtual Machine.
Resolution:
  - Icon: 256x256 and 128x128 PNG
  - Screenshot: 1280x720 (16:9 standard for Geminux Store / GNOME Software)
"""

import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def render_icon(size=256, path="branding/icons/geminux-vm.png"):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    scale = size / 128.0

    # Rounded base container
    pad = int(8 * scale)
    r = int(26 * scale)
    draw.rounded_rectangle(
        [pad, pad, size - pad, size - pad],
        radius=r,
        fill=(11, 19, 41, 255),
        outline=(30, 41, 59, 255),
        width=int(2 * scale)
    )

    # Outer monitor bezel
    m_x1, m_y1 = int(20 * scale), int(22 * scale)
    m_x2, m_y2 = int(108 * scale), int(88 * scale)
    draw.rounded_rectangle(
        [m_x1, m_y1, m_x2, m_y2],
        radius=int(10 * scale),
        fill=(10, 16, 29, 255),
        outline=(0, 210, 255, 255),
        width=int(2.5 * scale)
    )

    # Monitor stand
    s_top_w = int(24 * scale)
    s_bot_w = int(28 * scale)
    s_mid_x = size // 2
    s_y1 = int(88 * scale)
    s_y2 = int(102 * scale)
    stand_pts = [
        (s_mid_x - s_top_w // 2, s_y1),
        (s_mid_x - s_bot_w // 2, s_y2),
        (s_mid_x + s_bot_w // 2, s_y2),
        (s_mid_x + s_top_w // 2, s_y1)
    ]
    draw.polygon(stand_pts, fill=(30, 41, 59, 255), outline=(0, 210, 255, 255))
    draw.rounded_rectangle(
        [int(42 * scale), s_y2, int(86 * scale), s_y2 + int(4 * scale)],
        radius=int(2 * scale),
        fill=(0, 210, 255, 255)
    )

    # VM Layer 1: Windows (Top Left)
    w_x1, w_y1 = int(28 * scale), int(30 * scale)
    w_x2, w_y2 = int(60 * scale), int(52 * scale)
    draw.rounded_rectangle([w_x1, w_y1, w_x2, w_y2], radius=int(3 * scale), fill=(2, 132, 199, 100), outline=(56, 189, 248, 200), width=int(1 * scale))
    # 4 tiles
    tile_w, tile_h = int(10 * scale), int(6 * scale)
    t_gap = int(2 * scale)
    draw.rectangle([w_x1 + int(4*scale), w_y1 + int(4*scale), w_x1 + int(4*scale) + tile_w, w_y1 + int(4*scale) + tile_h], fill=(56, 189, 248, 240))
    draw.rectangle([w_x1 + int(4*scale) + tile_w + t_gap, w_y1 + int(4*scale), w_x1 + int(4*scale) + 2*tile_w + t_gap, w_y1 + int(4*scale) + tile_h], fill=(56, 189, 248, 240))
    draw.rectangle([w_x1 + int(4*scale), w_y1 + int(4*scale) + tile_h + t_gap, w_x1 + int(4*scale) + tile_w, w_y1 + int(4*scale) + 2*tile_h + t_gap], fill=(56, 189, 248, 240))
    draw.rectangle([w_x1 + int(4*scale) + tile_w + t_gap, w_y1 + int(4*scale) + tile_h + t_gap, w_x1 + int(4*scale) + 2*tile_w + t_gap, w_y1 + int(4*scale) + 2*tile_h + t_gap], fill=(56, 189, 248, 240))

    # VM Layer 2: macOS (Top Right)
    m_x1_sub, m_y1_sub = int(68 * scale), int(30 * scale)
    m_x2_sub, m_y2_sub = int(100 * scale), int(52 * scale)
    draw.rounded_rectangle([m_x1_sub, m_y1_sub, m_x2_sub, m_y2_sub], radius=int(3 * scale), fill=(71, 85, 105, 100), outline=(148, 163, 184, 200), width=int(1 * scale))
    # Apple shape hint
    draw.ellipse([m_x1_sub + int(12*scale), m_y1_sub + int(5*scale), m_x1_sub + int(20*scale), m_y1_sub + int(16*scale)], fill=(241, 245, 249, 240))

    # VM Layer 3: Main Central Active VM (Geminux / Linux) with Glowing Neon Bezel
    f_x1, f_y1 = int(36 * scale), int(44 * scale)
    f_x2, f_y2 = int(92 * scale), int(80 * scale)
    draw.rounded_rectangle([f_x1, f_y1, f_x2, f_y2], radius=int(6 * scale), fill=(11, 19, 43, 255), outline=(0, 242, 254, 255), width=int(2 * scale))

    # Header window dots
    draw.ellipse([int(41*scale), int(48*scale), int(45*scale), int(52*scale)], fill=(248, 113, 113, 255))
    draw.ellipse([int(47*scale), int(48*scale), int(51*scale), int(52*scale)], fill=(250, 204, 21, 255))
    draw.ellipse([int(53*scale), int(48*scale), int(57*scale), int(52*scale)], fill=(74, 222, 128, 255))

    # Geminux Twin Crystals in active VM
    cx, cy = int(64 * scale), int(64 * scale)
    c_left = [(cx - int(7*scale), cy - int(9*scale)), (cx, cy - int(3*scale)), (cx - int(7*scale), cy + int(10*scale)), (cx - int(14*scale), cy)]
    c_right = [(cx + int(7*scale), cy - int(9*scale)), (cx + int(14*scale), cy), (cx + int(7*scale), cy + int(10*scale)), (cx, cy - int(3*scale))]
    c_center = [(cx, cy - int(3*scale)), (cx + int(3*scale), cy + int(1*scale)), (cx, cy + int(5*scale)), (cx - int(3*scale), cy + int(1*scale))]

    draw.polygon(c_left, fill=(0, 210, 255, 255))
    draw.polygon(c_right, fill=(0, 114, 255, 255))
    draw.polygon(c_center, fill=(255, 255, 255, 255))

    # Lightning Badge (KVM Hardware Acceleration)
    b_cx, b_cy = int(98 * scale), int(24 * scale)
    b_r = int(10 * scale)
    draw.ellipse([b_cx - b_r, b_cy - b_r, b_cx + b_r, b_cy + b_r], fill=(2, 132, 199, 255), outline=(255, 255, 255, 255), width=int(1.5 * scale))
    bolt = [
        (b_cx, b_cy - int(7*scale)),
        (b_cx - int(5*scale), b_cy + int(1*scale)),
        (b_cx - int(1*scale), b_cy + int(1*scale)),
        (b_cx - int(2*scale), b_cy + int(7*scale)),
        (b_cx + int(4*scale), b_cy - int(1*scale)),
        (b_cx, b_cy - int(1*scale))
    ]
    draw.polygon(bolt, fill=(254, 240, 138, 255))

    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path, "PNG", optimize=True)
    print(f"Icon rendered to: {path}")


def render_screenshot():
    width, height = 1280, 720

    # 1. Base Wallpaper
    wallpaper_path = "branding/wallpaper/geminux-default.png"
    if os.path.exists(wallpaper_path):
        bg = Image.open(wallpaper_path).convert("RGBA")
        bg = bg.resize((width, height), Image.Resampling.LANCZOS)
    else:
        bg = Image.new("RGBA", (width, height), (11, 15, 23, 255))

    # 2. GNOME Top Bar (36px)
    top_bar = Image.new("RGBA", (width, 36), (10, 15, 26, 230))
    bg.paste(top_bar, (0, 0), top_bar)

    draw = ImageDraw.Draw(bg)

    font_sans = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    font_bold = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

    f_top = ImageFont.truetype(font_sans, 13)
    f_top_clock = ImageFont.truetype(font_bold, 13)
    f_title = ImageFont.truetype(font_bold, 14)
    f_sub = ImageFont.truetype(font_sans, 11)
    f_ui_bold = ImageFont.truetype(font_bold, 13)
    f_ui = ImageFont.truetype(font_sans, 13)
    f_btn = ImageFont.truetype(font_bold, 12)
    f_badge = ImageFont.truetype(font_bold, 11)
    f_big = ImageFont.truetype(font_bold, 20)

    # Top Bar Text
    draw.text((18, 10), "Atividades", font=f_top, fill=(240, 240, 240, 255))
    clock_text = "Ter, 8 de Set  15:30"
    cw = draw.textlength(clock_text, font=f_top_clock)
    draw.text(((width - cw) // 2, 10), clock_text, font=f_top_clock, fill=(240, 240, 240, 255))
    draw.text((width - 100, 10), "Geminux OS", font=f_top, fill=(0, 210, 255, 255))

    # 3. Application Window (940x560)
    win_w, win_h = 940, 560
    win_x = (width - win_w) // 2
    win_y = (height - win_h) // 2 + 16

    # Soft Shadow
    shadow = Image.new("RGBA", (win_w + 40, win_h + 40), (0, 0, 0, 0))
    sh_draw = ImageDraw.Draw(shadow)
    sh_draw.rounded_rectangle([20, 20, win_w + 20, win_h + 20], radius=16, fill=(0, 0, 0, 140))
    shadow = shadow.filter(ImageFilter.GaussianBlur(16))
    bg.paste(shadow, (win_x - 20, win_y - 20), shadow)

    # Window Canvas
    win = Image.new("RGBA", (win_w, win_h), (0, 0, 0, 0))
    wd = ImageDraw.Draw(win)

    # Window Ground
    wd.rounded_rectangle([0, 0, win_w, win_h], radius=12, fill=(11, 15, 23, 255), outline=(34, 45, 61, 255), width=1)

    # Headerbar (50px)
    wd.rounded_rectangle([0, 0, win_w, 50], radius=12, fill=(15, 20, 31, 255))
    wd.rectangle([0, 38, win_w, 50], fill=(15, 20, 31, 255)) # flatten bottom corners
    wd.line([(0, 50), (win_w, 50)], fill=(34, 45, 61, 255), width=1)

    # Window Controls (Close, Minimize, Maximize)
    wd.ellipse([win_w - 32, 18, win_w - 18, 32], fill=(239, 68, 68, 255))
    wd.ellipse([win_w - 56, 18, win_w - 42, 32], fill=(245, 158, 11, 255))
    wd.ellipse([win_w - 80, 18, win_w - 66, 32], fill=(16, 185, 129, 255))

    # Header Title & Subtitle
    title_text = "Geminux Virtual Machine"
    wd.text((180, 10), title_text, font=f_title, fill=(240, 246, 252, 255))
    wd.text((180, 30), "Gerenciador de Máquinas Virtuais (Windows, Linux, macOS)", font=f_sub, fill=(0, 210, 255, 255))

    # "+ Nova Máquina" Button
    wd.rounded_rectangle([16, 10, 150, 40], radius=8, fill=(0, 153, 204, 255))
    wd.text((32, 17), "+ Nova Máquina", font=f_btn, fill=(255, 255, 255, 255))

    # --- SIDEBAR (300px wide) ---
    sidebar_w = 310
    wd.rectangle([0, 51, sidebar_w, win_h], fill=(13, 18, 28, 255))
    wd.line([(sidebar_w, 51), (sidebar_w, win_h)], fill=(34, 45, 61, 255), width=1)

    wd.text((18, 66), "SUAS MÁQUINAS VIRTUAIS", font=f_sub, fill=(139, 148, 158, 255))

    # List of VMs
    vms = [
        {"name": "Windows 11 Pro", "os": "Windows", "ram": "4096MB", "disk": "64GB", "icon": "🪟", "running": True, "selected": True},
        {"name": "Ubuntu 26.04 LTS", "os": "Linux", "ram": "2048MB", "disk": "30GB", "icon": "🐧", "running": False, "selected": False},
        {"name": "macOS Sonoma", "os": "macOS", "ram": "4096MB", "disk": "64GB", "icon": "🍎", "running": False, "selected": False},
        {"name": "Debian 13 Bookworm", "os": "Linux", "ram": "2048MB", "disk": "25GB", "icon": "🐧", "running": False, "selected": False}
    ]

    row_y = 92
    for vm in vms:
        if vm["selected"]:
            wd.rounded_rectangle([10, row_y, sidebar_w - 10, row_y + 60], radius=10, fill=(24, 35, 51, 255), outline=(0, 210, 255, 255), width=1)
        else:
            wd.rounded_rectangle([10, row_y, sidebar_w - 10, row_y + 60], radius=10, fill=(20, 26, 36, 255), outline=(34, 45, 61, 255), width=1)

        # OS Icon box
        wd.rounded_rectangle([20, row_y + 12, 54, row_y + 46], radius=6, fill=(26, 34, 48, 255))
        # Text icon fallback
        wd.text((26, row_y + 16), vm["icon"], font=f_ui_bold, fill=(255, 255, 255, 255))

        # VM Name and specs
        wd.text((64, row_y + 12), vm["name"], font=f_ui_bold, fill=(255, 255, 255, 255) if vm["selected"] else (220, 230, 240, 255))
        sub_text = f"{vm['os']} • {vm['ram']} RAM • {vm['disk']}"
        wd.text((64, row_y + 34), sub_text, font=f_sub, fill=(139, 148, 158, 255))

        # Status ball
        status_color = (63, 185, 80, 255) if vm["running"] else (139, 148, 158, 255)
        wd.ellipse([sidebar_w - 30, row_y + 24, sidebar_w - 20, row_y + 34], fill=status_color)

        row_y += 70

    # --- DETAIL VIEW (RIGHT PANEL) ---
    rx = sidebar_w + 24
    ry = 68

    # Title & Badge
    wd.text((rx, ry), "Windows 11 Pro", font=f_big, fill=(255, 255, 255, 255))
    wd.text((rx, ry + 28), "Sistema Operacional: Windows 11 (64-bit) com Otimizações Hyper-V", font=f_ui, fill=(139, 148, 158, 255))

    # Badge Running
    wd.rounded_rectangle([win_w - 160, ry + 4, win_w - 24, ry + 32], radius=14, fill=(46, 160, 67, 50), outline=(63, 185, 80, 100), width=1)
    wd.ellipse([win_w - 150, ry + 14, win_w - 142, ry + 22], fill=(63, 185, 80, 255))
    wd.text((win_w - 134, ry + 10), "Em Execução", font=f_badge, fill=(63, 185, 80, 255))

    # Action Buttons Bar
    by = ry + 64
    # Start button (disabled / running)
    wd.rounded_rectangle([rx, by, rx + 160, by + 40], radius=8, fill=(30, 45, 65, 255))
    wd.text((rx + 24, by + 12), "▶ Iniciar Máquina", font=f_btn, fill=(139, 148, 158, 255))

    # Stop button (active)
    wd.rounded_rectangle([rx + 172, by, rx + 290, by + 40], radius=8, fill=(218, 54, 51, 255))
    wd.text((rx + 196, by + 12), "⏹ Desligar", font=f_btn, fill=(255, 255, 255, 255))

    # Delete button
    wd.rounded_rectangle([win_w - 130, by, win_w - 24, by + 40], radius=8, fill=(0, 0, 0, 0), outline=(248, 81, 73, 100), width=1)
    wd.text((win_w - 110, by + 12), "Excluir VM", font=f_btn, fill=(248, 81, 73, 255))

    # Specs Card
    cy = by + 56
    card_w = win_w - rx - 24
    card_h = 220
    wd.rounded_rectangle([rx, cy, rx + card_w, cy + card_h], radius=12, fill=(20, 26, 36, 255), outline=(34, 45, 61, 255), width=1)

    wd.text((rx + 18, cy + 16), "Especificações da Máquina", font=f_ui_bold, fill=(240, 246, 252, 255))

    # Grid details
    labels = [
        ("Memória RAM:", "4096 MB (4.0 GB)"),
        ("Processador:", "2 vCPUs (KVM Hardware Acceleration)"),
        ("Disco Virtual:", "64 GB (win11_pro.qcow2)"),
        ("CD-ROM / ISO:", "Win11_24H2_BrazilianPortuguese_x64.iso"),
        ("Vídeo & Áudio:", "VirtIO VGA acelerado • Intel HDAudio"),
        ("Rede Virtual:", "VirtIO Network Adapter (NAT integrado)")
    ]

    gy = cy + 48
    for label, val in labels:
        wd.text((rx + 18, gy), label, font=f_ui, fill=(139, 148, 158, 255))
        wd.text((rx + 170, gy), val, font=f_ui_bold, fill=(220, 230, 245, 255))
        gy += 26

    # Bottom Info Card
    iy = cy + card_h + 16
    wd.rounded_rectangle([rx, iy, rx + card_w, iy + 56], radius=10, fill=(15, 22, 34, 255), outline=(0, 210, 255, 80), width=1)
    wd.text((rx + 18, iy + 14), "⚡", font=f_big, fill=(0, 210, 255, 255))
    wd.text((rx + 50, iy + 12), "Aceleração de hardware Linux KVM ativada automaticamente.", font=f_ui_bold, fill=(240, 246, 252, 255))
    wd.text((rx + 50, iy + 32), "Suporte nativo a Windows 10/11, distribuições Linux e macOS com máxima performance.", font=f_sub, fill=(139, 148, 158, 255))

    # Paste window on desktop
    bg.paste(win, (win_x, win_y), win)

    # Save
    out_dir = "branding/screenshots"
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "geminux-vm.png")
    bg.convert("RGB").save(out_path, "PNG", optimize=True)
    print(f"Screenshot rendered to: {out_path}")

if __name__ == "__main__":
    render_icon(size=256, path="branding/icons/geminux-vm.png")
    render_screenshot()
