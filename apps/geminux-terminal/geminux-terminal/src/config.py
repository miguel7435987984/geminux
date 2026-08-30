"""
Configuration Manager for Geminux Terminal
"""
import os
import configparser

DEFAULT_CONFIG = {
    'General': {
        'theme': 'Catppuccin Mocha',
        'font_family': 'Monospace',
        'font_size': '12',
        'opacity': '0.90',
        'audible_bell': 'False',
        'cursor_shape': 'BLOCK',  # BLOCK, IBEAM, UNDERLINE
        'cursor_blink': 'SYSTEM',  # SYSTEM, ON, OFF
        'scroll_on_output': 'False',
        'scroll_on_keystroke': 'True',
        'scrollback_lines': '10000',
        'custom_shell': '',
        'custom_command': '',
        'use_custom_command': 'False',
        'show_menubar': 'False',
        'window_width': '950',
        'window_height': '580',
        'header_bar': 'True',
        'blur_background': 'True',
        'padding': '14',
        'allow_bold': 'True',
    }
}

class ConfigManager:
    def __init__(self):
        self.config_dir = os.path.expanduser('~/.config/geminux-terminal')
        self.config_file = os.path.join(self.config_dir, 'config.ini')
        self.themes_file = os.path.join(self.config_dir, 'custom_themes.ini')

        # System presets
        base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
        self.sys_themes_file = os.path.join(base_dir, 'data', 'themes', 'presets.ini')
        if not os.path.exists(self.sys_themes_file):
            self.sys_themes_file = '/usr/share/geminux-terminal/themes/presets.ini'

        self.config = configparser.ConfigParser()
        self.themes = configparser.ConfigParser()
        self._ensure_config_exists()
        self.load()

    def _ensure_config_exists(self):
        os.makedirs(self.config_dir, exist_ok=True)
        if not os.path.exists(self.config_file):
            self.config.read_dict(DEFAULT_CONFIG)
            with open(self.config_file, 'w', encoding='utf-8') as f:
                self.config.write(f)

    def load(self):
        # Load themes: first system presets, then user custom themes
        self.themes = configparser.ConfigParser()
        if os.path.exists(self.sys_themes_file):
            self.themes.read(self.sys_themes_file, encoding='utf-8')
        if os.path.exists(self.themes_file):
            self.themes.read(self.themes_file, encoding='utf-8')

        # Load user config
        self.config = configparser.ConfigParser()
        self.config.read_dict(DEFAULT_CONFIG)
        if os.path.exists(self.config_file):
            self.config.read(self.config_file, encoding='utf-8')

    def save(self):
        os.makedirs(self.config_dir, exist_ok=True)
        with open(self.config_file, 'w', encoding='utf-8') as f:
            self.config.write(f)

    def get(self, section, key, fallback=None):
        return self.config.get(section, key, fallback=fallback)

    def getint(self, section, key, fallback=0):
        return self.config.getint(section, key, fallback=fallback)

    def getfloat(self, section, key, fallback=1.0):
        return self.config.getfloat(section, key, fallback=fallback)

    def getboolean(self, section, key, fallback=False):
        return self.config.getboolean(section, key, fallback=fallback)

    def set(self, section, key, value):
        if not self.config.has_section(section):
            self.config.add_section(section)
        self.config.set(section, key, str(value))

    def get_theme_names(self):
        return self.themes.sections()

    def get_theme_colors(self, theme_name):
        if theme_name in self.themes:
            t = self.themes[theme_name]
            return {
                'background': t.get('background', '#1e1e2e'),
                'foreground': t.get('foreground', '#cdd6f4'),
                'cursor': t.get('cursor', '#f5e0dc'),
                'cursor_foreground': t.get('cursor_foreground', '#11111b'),
                'palette': [c.strip() for c in t.get('palette', '').split(':') if c.strip()]
            }
        # Fallback default (Catppuccin Mocha)
        return {
            'background': '#1e1e2e',
            'foreground': '#cdd6f4',
            'cursor': '#f5e0dc',
            'cursor_foreground': '#11111b',
            'palette': [
                '#45475a','#f38ba8','#a6e3a1','#f9e2af','#89b4fa','#f5c2e7','#94e2d5','#bac2de',
                '#585b70','#f38ba8','#a6e3a1','#f9e2af','#89b4fa','#f5c2e7','#94e2d5','#a6adc8'
            ]
        }

    def save_custom_theme(self, name, background, foreground, cursor, cursor_foreground, palette_list):
        custom_cfg = configparser.ConfigParser()
        if os.path.exists(self.themes_file):
            custom_cfg.read(self.themes_file, encoding='utf-8')

        palette_str = ':'.join(palette_list)
        custom_cfg[name] = {
            'background': background,
            'foreground': foreground,
            'cursor': cursor,
            'cursor_foreground': cursor_foreground,
            'palette': palette_str
        }
        with open(self.themes_file, 'w', encoding='utf-8') as f:
            custom_cfg.write(f)
        self.load()
