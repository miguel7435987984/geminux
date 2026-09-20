"""
Custom CSS generator for Geminux Terminal Modern UI
"""

def generate_css(theme_colors, opacity=0.92, font_family="Monospace", font_size=12):
    bg = theme_colors.get('background', '#1e1e2e')
    fg = theme_colors.get('foreground', '#cdd6f4')
    accent = theme_colors.get('palette', ['#89b4fa'])[4] if len(theme_colors.get('palette', [])) > 4 else '#89b4fa'

    # Convert hex to rgba for glassmorphism
    r, g, b = 30, 30, 46
    if bg.startswith('#') and len(bg) == 7:
        r = int(bg[1:3], 16)
        g = int(bg[3:5], 16)
        b = int(bg[5:7], 16)

    header_bg = f"rgba({max(0, r-8)}, {max(0, g-8)}, {max(0, b-8)}, {min(1.0, opacity + 0.08):.2f})"
    border_color = f"rgba(255, 255, 255, 0.08)"
    hover_bg = f"rgba(255, 255, 255, 0.12)"
    active_tab_bg = f"rgba({r+25}, {g+25}, {b+25}, 0.75)"

    return f"""
    /* Geminux Terminal Modern Glassmorphism Styling */
    window.geminux-window {{
        background-color: transparent;
        color: {fg};
    }}

    headerbar.geminux-headerbar {{
        background-color: {header_bg};
        color: {fg};
        border-bottom: 1px solid {border_color};
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.35);
        padding: 4px 8px;
        min-height: 38px;
    }}

    headerbar.geminux-headerbar button {{
        background-color: transparent;
        color: {fg};
        border: 1px solid transparent;
        border-radius: 8px;
        padding: 4px 8px;
        margin: 2px;
        transition: all 200ms ease;
    }}

    headerbar.geminux-headerbar button:hover {{
        background-color: {hover_bg};
        border: 1px solid {border_color};
    }}

    headerbar.geminux-headerbar button:active {{
        background-color: {active_tab_bg};
    }}

    /* Tabs Styling */
    notebook.geminux-notebook > header {{
        background-color: {header_bg};
        border-bottom: 1px solid {border_color};
        padding: 2px 6px;
    }}

    notebook.geminux-notebook tab {{
        background-color: transparent;
        color: {fg};
        border: 1px solid transparent;
        border-radius: 8px 8px 0 0;
        padding: 4px 12px;
        margin: 0 3px;
        font-weight: 500;
        transition: all 150ms ease;
    }}

    notebook.geminux-notebook tab:hover {{
        background-color: {hover_bg};
    }}

    notebook.geminux-notebook tab:checked {{
        background-color: {active_tab_bg};
        border-bottom: 2px solid {accent};
        color: #ffffff;
    }}

    notebook.geminux-notebook tab button {{
        min-height: 16px;
        min-width: 16px;
        padding: 0;
        margin-left: 6px;
        border-radius: 50%;
        background-color: transparent;
    }}

    notebook.geminux-notebook tab button:hover {{
        background-color: rgba(255, 100, 100, 0.3);
        color: #ff6e6e;
    }}

    /* Search bar styling */
    .geminux-search-box {{
        background-color: {header_bg};
        border: 1px solid {border_color};
        border-radius: 10px;
        padding: 6px 12px;
        margin: 6px 16px;
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);
    }}

    .geminux-search-box entry {{
        background-color: rgba(0, 0, 0, 0.25);
        color: {fg};
        border: 1px solid {border_color};
        border-radius: 6px;
        padding: 4px 8px;
    }}

    /* Dialog / Preferences Styling */
    dialog.geminux-dialog {{
        background-color: {bg};
        color: {fg};
    }}

    dialog.geminux-dialog .sidebar {{
        background-color: {header_bg};
        border-right: 1px solid {border_color};
    }}

    /* Splitter pane handle */
    paned > separator {{
        background-color: {border_color};
        min-width: 3px;
        min-height: 3px;
    }}

    paned > separator:hover {{
        background-color: {accent};
    }}

    /* Scrollbars */
    scrollbar.geminux-scrollbar {{
        background-color: transparent;
        transition: all 300ms ease;
    }}

    scrollbar.geminux-scrollbar slider {{
        background-color: rgba(255, 255, 255, 0.2);
        border-radius: 10px;
        min-width: 6px;
        min-height: 20px;
        border: none;
    }}

    scrollbar.geminux-scrollbar slider:hover {{
        background-color: {accent};
    }}
    """
