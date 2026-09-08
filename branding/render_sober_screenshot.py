#!/usr/bin/env python3
"""
Render official AppStream screenshot for Sober Fix in Geminux OS.
Resolution: 1280x720 (16:9 standard).
"""

import os
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_screenshot():
    width, height = 1280, 720

    # 1. Base Wallpaper
    wallpaper_path = "branding/wallpaper/geminux-default.png"
    if os.path.exists(wallpaper_path):
        bg = Image.open(wallpaper_path).convert("RGBA")
        bg = bg.resize((width, height), Image.Resampling.LANCZOS)
    else:
        bg = Image.new("RGBA", (width, height), (15, 23, 42, 255))

    # 2. GNOME Top Bar (36px high)
    top_bar = Image.new("RGBA", (width, 36), (10, 15, 26, 230))
    bg.paste(top_bar, (0, 0), top_bar)

    draw = ImageDraw.Draw(bg)

    # Fonts
    font_sans = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    font_bold = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
    font_mono = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
    font_mono_bold = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"

    f_top = ImageFont.truetype(font_sans, 13)
    f_top_clock = ImageFont.truetype(font_bold, 13)
    f_title = ImageFont.truetype(font_bold, 13)
    f_terminal = ImageFont.truetype(font_mono, 14)
    f_terminal_bold = ImageFont.truetype(font_mono_bold, 14)

    # Top Bar Text
    draw.text((18, 10), "Atividades", font=f_top, fill=(240, 240, 240, 255))
    clock_text = "Ter, 8 de Set  14:30"
    cw = draw.textlength(clock_text, font=f_top_clock)
    draw.text(((width - cw) // 2, 10), clock_text, font=f_top_clock, fill=(240, 240, 240, 255))
    draw.text((width - 90, 10), "Geminux OS", font=f_top, fill=(180, 200, 220, 255))

    # 3. Terminal Window Dimensions
    win_w, win_h = 880, 520
    win_x = (width - win_w) // 2
    win_y = (height - win_h) // 2 + 15

    # Shadow
    shadow = Image.new("RGBA", (win_w + 40, win_h + 40), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle([20, 20, win_w + 20, win_h + 20], radius=16, fill=(0, 0, 0, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    bg.paste(shadow, (win_x - 20, win_y - 20), shadow)

    # Window Base
    win_surf = Image.new("RGBA", (win_w, win_h), (0, 0, 0, 0))
    win_draw = ImageDraw.Draw(win_surf)
    # Background
    win_draw.rounded_rectangle([0, 0, win_w, win_h], radius=12, fill=(20, 24, 34, 245))
    # Titlebar (42px)
    win_draw.rounded_rectangle([0, 0, win_w, 42], radius=12, fill=(30, 36, 50, 255))
    win_draw.rectangle([0, 30, win_w, 42], fill=(30, 36, 50, 255)) # flatten bottom corners
    win_draw.line([(0, 42), (win_w, 42)], fill=(45, 55, 75, 255), width=1)

    # Window Controls (Close, Minimize, Maximize)
    win_draw.ellipse([win_w - 32, 14, win_w - 18, 28], fill=(239, 68, 68, 255)) # Close
    win_draw.ellipse([win_w - 56, 14, win_w - 42, 28], fill=(245, 158, 11, 255)) # Min
    win_draw.ellipse([win_w - 80, 14, win_w - 66, 28], fill=(16, 185, 129, 255)) # Max

    # Title
    title = "Geminux Terminal — sober-fix"
    tw = win_draw.textlength(title, font=f_title)
    win_draw.text(((win_w - tw) // 2, 13), title, font=f_title, fill=(210, 220, 235, 255))

    # Terminal Content Lines
    cx = 24
    cy = 58
    line_h = 22

    def draw_term_line(text, color=(220, 225, 235, 255), bold=False):
        nonlocal cy
        f = f_terminal_bold if bold else f_terminal
        win_draw.text((cx, cy), text, font=f, fill=color)
        cy += line_h

    # Prompt
    p_user = "miguel@geminux"
    p_sep = ":"
    p_path = "~"
    p_sym = "$ "

    x = cx
    win_draw.text((x, cy), p_user, font=f_terminal_bold, fill=(56, 189, 248, 255))
    x += int(win_draw.textlength(p_user, font=f_terminal_bold))
    win_draw.text((x, cy), p_sep, font=f_terminal, fill=(200, 200, 200, 255))
    x += int(win_draw.textlength(p_sep, font=f_terminal))
    win_draw.text((x, cy), p_path, font=f_terminal_bold, fill=(168, 85, 247, 255))
    x += int(win_draw.textlength(p_path, font=f_terminal_bold))
    win_draw.text((x, cy), p_sym, font=f_terminal, fill=(200, 200, 200, 255))
    x += int(win_draw.textlength(p_sym, font=f_terminal))
    win_draw.text((x, cy), "sober-fix", font=f_terminal_bold, fill=(255, 255, 255, 255))
    cy += line_h + 4

    cyan = (56, 189, 248, 255)
    yellow = (250, 204, 21, 255)
    green = (74, 222, 128, 255)
    dim_white = (226, 232, 240, 255)

    draw_term_line("=====================================================", cyan, bold=True)
    draw_term_line("   🛠️  Geminux OS - Reparador do Sober (Roblox)       ", cyan, bold=True)
    draw_term_line("=====================================================", cyan, bold=True)
    cy += 6

    draw_term_line("==> Verificando arquivos de cache e temporários do Sober...", yellow, bold=True)
    cy += 2
    draw_term_line("  🧹 Limpando cache: ~/.var/app/org.vinegarhq.Sober/cache", dim_white)
    draw_term_line("  🧹 Limpando cache do usuário: ~/.cache/org.vinegarhq.Sober", dim_white)
    draw_term_line("  ⚙️  Finalizando processos em segundo plano do Sober/Roblox...", dim_white)
    cy += 8

    draw_term_line("=====================================================", green, bold=True)
    draw_term_line("   ✨ Cache do Sober limpo com sucesso!             ", green, bold=True)
    draw_term_line("   🚀 Você já pode abrir o Sober / Roblox agora.     ", green, bold=True)
    draw_term_line("=====================================================", green, bold=True)
    cy += 14

    # New prompt with cursor
    x = cx
    win_draw.text((x, cy), p_user, font=f_terminal_bold, fill=(56, 189, 248, 255))
    x += int(win_draw.textlength(p_user, font=f_terminal_bold))
    win_draw.text((x, cy), p_sep, font=f_terminal, fill=(200, 200, 200, 255))
    x += int(win_draw.textlength(p_sep, font=f_terminal))
    win_draw.text((x, cy), p_path, font=f_terminal_bold, fill=(168, 85, 247, 255))
    x += int(win_draw.textlength(p_path, font=f_terminal_bold))
    win_draw.text((x, cy), p_sym, font=f_terminal, fill=(200, 200, 200, 255))
    x += int(win_draw.textlength(p_sym, font=f_terminal))
    # Block cursor
    win_draw.rectangle([x + 2, cy + 2, x + 11, cy + 16], fill=(56, 189, 248, 255))

    # Paste terminal onto desktop
    bg.paste(win_surf, (win_x, win_y), win_surf)

    # Save
    out_dir = "branding/screenshots"
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "sober-fix.png")
    bg.convert("RGB").save(out_path, "PNG", optimize=True)
    print(f"Screenshot saved successfully to: {out_path}")

if __name__ == "__main__":
    create_screenshot()
