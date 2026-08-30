import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_wallpaper(path="branding/wallpaper/geminux-default.png", width=1920, height=1080):
    img = Image.new("RGBA", (width, height), (2, 4, 8, 255))
    draw = ImageDraw.Draw(img)

    # Radial gradient simulation
    cx, cy = width // 2, int(height * 0.45)
    max_r = int(math.hypot(cx, cy))
    for r in range(max_r, 0, -8):
        factor = 1.0 - (r / max_r)
        # Gradient from #020408 to #0b1b33
        r_col = int(2 + (11 - 2) * (factor ** 1.5))
        g_col = int(4 + (27 - 4) * (factor ** 1.5))
        b_col = int(8 + (51 - 8) * (factor ** 1.5))
        draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(r_col, g_col, b_col, 255))

    # Center Logo Crystals
    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    ol_draw = ImageDraw.Draw(overlay)

    # Left diamond
    p_left = [(cx - 80, cy - 140), (cx, cy - 40), (cx - 80, cy + 180), (cx - 160, cy + 20)]
    ol_draw.polygon(p_left, fill=(0, 210, 255, 230))

    # Right diamond
    p_right = [(cx + 80, cy - 140), (cx + 160, cy + 20), (cx + 80, cy + 180), (cx, cy - 40)]
    ol_draw.polygon(p_right, fill=(0, 114, 255, 230))

    # Center star
    p_center = [(cx, cy - 40), (cx + 40, cy + 20), (cx, cy + 80), (cx - 40, cy + 20)]
    ol_draw.polygon(p_center, fill=(255, 255, 255, 255))

    # Apply soft glow
    glow = overlay.filter(ImageFilter.GaussianBlur(14))
    img.paste(glow, (0, 0), glow)
    img.paste(overlay, (0, 0), overlay)

    # Add text
    final_draw = ImageDraw.Draw(img)
    final_draw.text((cx - 120, cy + 260), "GEMINUX", fill=(255, 255, 255, 255))
    final_draw.text((cx - 85, cy + 295), "SYSTEM LINUX", fill=(0, 210, 255, 255))

    img.convert("RGB").save(path, "PNG")
    print(f"Created: {path}")

def create_logo(path="branding/icons/geminux-logo.png", size=256):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = size // 2, size // 2

    # Crystals scaled
    p_left = [(cx - 40, cy - 70), (cx, cy - 20), (cx - 40, cy + 90), (cx - 80, cy + 10)]
    draw.polygon(p_left, fill=(0, 210, 255, 240))

    p_right = [(cx + 40, cy - 70), (cx + 80, cy + 10), (cx + 40, cy + 90), (cx, cy - 20)]
    draw.polygon(p_right, fill=(0, 114, 255, 240))

    p_center = [(cx, cy - 20), (cx + 20, cy + 10), (cx, cy + 40), (cx - 20, cy + 10)]
    draw.polygon(p_center, fill=(255, 255, 255, 255))

    img.save(path, "PNG")
    print(f"Created: {path}")

def create_prius_icon(path="branding/icons/prius-terminal.png", size=128):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Background rounded box
    draw.rounded_rectangle([8, 8, size - 8, size - 8], radius=24, fill=(15, 20, 28, 255), outline=(34, 50, 73, 255), width=3)

    # Prompt >_
    draw.line([(28, 50), (52, 70)], fill=(0, 210, 255, 255), width=7)
    draw.line([(52, 70), (28, 90)], fill=(0, 210, 255, 255), width=7)
    draw.rectangle([62, 78, 90, 88], fill=(0, 210, 255, 255))

    img.save(path, "PNG")
    print(f"Created: {path}")

if __name__ == "__main__":
    os.makedirs("branding/wallpaper", exist_ok=True)
    os.makedirs("branding/icons", exist_ok=True)
    create_wallpaper()
    create_logo()
    create_prius_icon()
