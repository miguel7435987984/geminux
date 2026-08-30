import cairosvg
import os

print("Rendering Geminux assets to PNG...")

try:
    cairosvg.svg2png(
        url="branding/wallpaper/geminux-default.svg",
        write_to="branding/wallpaper/geminux-default.png",
        output_width=1920,
        output_height=1080
    )
    cairosvg.svg2png(
        url="branding/icons/geminux-logo.svg",
        write_to="branding/icons/geminux-logo.png",
        output_width=256,
        output_height=256
    )
    cairosvg.svg2png(
        url="branding/icons/prius-terminal.svg",
        write_to="branding/icons/prius-terminal.png",
        output_width=128,
        output_height=128
    )
    print("All PNG assets generated via CairoSVG!")
except Exception as e:
    print("CairoSVG render error:", e)
