"""
Terminal Widget wrapper around Vte.Terminal with customization support
"""
import os
import re
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Vte', '2.91')
from gi.repository import Gtk, Vte, GLib, Gdk, Pango

def parse_hex_to_gdk(hex_str):
    color = Gdk.RGBA()
    if not color.parse(hex_str):
        color.parse('#ffffff')
    return color

class TerminalWidget(Gtk.Box):
    def __init__(self, config_manager, cwd=None):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.config_manager = config_manager
        self.cwd = cwd or os.path.expanduser('~')
        self.custom_title = None

        # Container with overlay for search and notifications
        self.overlay = Gtk.Overlay()
        self.pack_start(self.overlay, True, True, 0)

        # Vte Terminal
        self.vte = Vte.Terminal()
        self.vte.set_mouse_autohide(True)

        # Scrolled window
        self.scrolled = Gtk.ScrolledWindow()
        self.scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        self.scrolled.get_style_context().add_class('geminux-scrollbar')
        self.scrolled.add(self.vte)
        self.overlay.add(self.scrolled)

        # Search Bar Overlay
        self.search_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.search_box.get_style_context().add_class('geminux-search-box')
        self.search_box.set_halign(Gtk.Align.END)
        self.search_box.set_valign(Gtk.Align.START)
        self.search_box.set_no_show_all(True)

        self.search_entry = Gtk.SearchEntry()
        self.search_entry.set_width_chars(25)
        self.search_entry.connect('search-changed', self._on_search_changed)
        self.search_entry.connect('activate', self._on_search_next)
        self.search_box.pack_start(self.search_entry, True, True, 0)

        btn_prev = Gtk.Button.new_from_icon_name('go-up-symbolic', Gtk.IconSize.BUTTON)
        btn_prev.set_tooltip_text("Anterior (Shift+Enter)")
        btn_prev.connect('clicked', self._on_search_prev)
        self.search_box.pack_start(btn_prev, False, False, 0)

        btn_next = Gtk.Button.new_from_icon_name('go-down-symbolic', Gtk.IconSize.BUTTON)
        btn_next.set_tooltip_text("Próximo (Enter)")
        btn_next.connect('clicked', self._on_search_next)
        self.search_box.pack_start(btn_next, False, False, 0)

        btn_close_search = Gtk.Button.new_from_icon_name('window-close-symbolic', Gtk.IconSize.BUTTON)
        btn_close_search.connect('clicked', lambda b: self.hide_search())
        self.search_box.pack_start(btn_close_search, False, False, 0)

        self.overlay.add_overlay(self.search_box)

        # Regex URL matching for clickable links
        self._setup_url_matching()

        # Connect signals
        self.vte.connect('window-title-changed', self._on_title_changed)
        self.vte.connect('button-press-event', self._on_button_press)
        self.vte.connect('child-exited', self._on_child_exited)

        # Apply settings and spawn shell
        self.apply_config()
        self.spawn_shell()

    def _setup_url_matching(self):
        url_regex = r'(https?://[^\s<>"\']+|(www\.[^\s<>"\']+))'
        try:
            regex = Vte.Regex.new_for_match(url_regex, len(url_regex), GLib.RegexCompileFlags.OPTIMIZE)
            self.url_tag = self.vte.match_add_regex(regex, 0)
            self.vte.match_set_cursor_name(self.url_tag, 'pointer')
        except Exception as e:
            pass

    def apply_config(self):
        cfg = self.config_manager

        # Font
        font_family = cfg.get('General', 'font_family', 'Monospace')
        font_size = cfg.getint('General', 'font_size', 12)
        font_desc = Pango.FontDescription(f"{font_family} {font_size}")
        self.vte.set_font(font_desc)

        # Colors & Theme
        theme_name = cfg.get('General', 'theme', 'Catppuccin Mocha')
        colors = cfg.get_theme_colors(theme_name)
        opacity = cfg.getfloat('General', 'opacity', 0.90)

        fg_color = parse_hex_to_gdk(colors['foreground'])
        bg_color = parse_hex_to_gdk(colors['background'])
        # Set alpha on background for transparency
        bg_color.alpha = opacity

        cursor_color = parse_hex_to_gdk(colors['cursor'])
        cursor_fg_color = parse_hex_to_gdk(colors['cursor_foreground'])

        palette = [parse_hex_to_gdk(c) for c in colors['palette']]
        if len(palette) < 16:
            # fill up to 16
            palette += [fg_color] * (16 - len(palette))

        self.vte.set_colors(fg_color, bg_color, palette[:16])
        self.vte.set_color_cursor(cursor_color)
        self.vte.set_color_cursor_foreground(cursor_fg_color)

        # Cursor Shape
        cursor_shape_str = cfg.get('General', 'cursor_shape', 'BLOCK').upper()
        if cursor_shape_str == 'IBEAM':
            self.vte.set_cursor_shape(Vte.CursorShape.IBEAM)
        elif cursor_shape_str == 'UNDERLINE':
            self.vte.set_cursor_shape(Vte.CursorShape.UNDERLINE)
        else:
            self.vte.set_cursor_shape(Vte.CursorShape.BLOCK)

        # Cursor Blink
        cursor_blink_str = cfg.get('General', 'cursor_blink', 'SYSTEM').upper()
        if cursor_blink_str == 'ON':
            self.vte.set_cursor_blink_mode(Vte.CursorBlinkMode.ON)
        elif cursor_blink_str == 'OFF':
            self.vte.set_cursor_blink_mode(Vte.CursorBlinkMode.OFF)
        else:
            self.vte.set_cursor_blink_mode(Vte.CursorBlinkMode.SYSTEM)

        # Scroll & Bell
        self.vte.set_scroll_on_output(cfg.getboolean('General', 'scroll_on_output', False))
        self.vte.set_scroll_on_keystroke(cfg.getboolean('General', 'scroll_on_keystroke', True))
        self.vte.set_scrollback_lines(cfg.getint('General', 'scrollback_lines', 10000))
        self.vte.set_audible_bell(cfg.getboolean('General', 'audible_bell', False))
        self.vte.set_allow_bold(cfg.getboolean('General', 'allow_bold', True))

    def spawn_shell(self):
        cfg = self.config_manager
        shell = os.environ.get('SHELL', '/bin/bash')

        if cfg.getboolean('General', 'use_custom_command', False):
            custom_cmd = cfg.get('General', 'custom_command', '')
            if custom_cmd:
                argv = ['/bin/sh', '-c', custom_cmd]
            else:
                argv = [shell]
        else:
            custom_shell = cfg.get('General', 'custom_shell', '')
            if custom_shell and os.path.exists(custom_shell):
                shell = custom_shell
            argv = [shell]

        env = os.environ.copy()
        env['TERM'] = 'xterm-256color'
        env['COLORTERM'] = 'truecolor'

        try:
            self.vte.spawn_sync(
                Vte.PtyFlags.DEFAULT,
                self.cwd,
                argv,
                [f"{k}={v}" for k, v in env.items()],
                GLib.SpawnFlags.SEARCH_PATH,
                None,
                None
            )
        except Exception as e:
            print(f"Erro ao iniciar shell: {e}")

    def _on_title_changed(self, terminal):
        title = terminal.get_window_title() or "Terminal"
        # Emit or notify parent tab
        parent = self.get_parent()
        while parent:
            if hasattr(parent, 'update_tab_title'):
                parent.update_tab_title(self, title)
                break
            parent = parent.get_parent()

    def get_current_title(self):
        if self.custom_title:
            return self.custom_title
        t = self.vte.get_window_title()
        if t:
            # Clean title (e.g. user@host: ~/dir)
            return t.split()[-1] if '/' in t else t
        return "Terminal"

    def _on_button_press(self, terminal, event):
        if event.button == 3:  # Right Click Context Menu
            self._show_context_menu(event)
            return True
        elif event.button == 1 and (event.state & Gdk.ModifierType.CONTROL_MASK):
            # Ctrl+Click on URL
            match = self.vte.match_check_event(event)
            if match:
                url = match[0]
                if not url.startswith('http'):
                    url = 'https://' + url
                Gtk.show_uri_on_window(None, url, Gdk.CURRENT_TIME)
                return True
        return False

    def _show_context_menu(self, event):
        menu = Gtk.Menu()

        item_copy = Gtk.MenuItem(label="Copiar")
        item_copy.connect('activate', lambda x: self.copy_clipboard())
        menu.append(item_copy)

        item_paste = Gtk.MenuItem(label="Colar")
        item_paste.connect('activate', lambda x: self.paste_clipboard())
        menu.append(item_paste)

        menu.append(Gtk.SeparatorMenuItem())

        item_search = Gtk.MenuItem(label="Buscar...")
        item_search.connect('activate', lambda x: self.show_search())
        menu.append(item_search)

        item_clear = Gtk.MenuItem(label="Limpar Terminal")
        item_clear.connect('activate', lambda x: self.vte.reset(True, True))
        menu.append(item_clear)

        menu.append(Gtk.SeparatorMenuItem())

        # Split options
        item_split_h = Gtk.MenuItem(label="Dividir Horizontalmente")
        item_split_h.connect('activate', lambda x: self._emit_split('horizontal'))
        menu.append(item_split_h)

        item_split_v = Gtk.MenuItem(label="Dividir Verticalmente")
        item_split_v.connect('activate', lambda x: self._emit_split('vertical'))
        menu.append(item_split_v)

        menu.show_all()
        menu.popup_at_pointer(event)

    def _emit_split(self, direction):
        parent = self.get_parent()
        while parent:
            if hasattr(parent, 'split_terminal'):
                parent.split_terminal(self, direction)
                break
            parent = parent.get_parent()

    def _on_child_exited(self, terminal, status):
        parent = self.get_parent()
        while parent:
            if hasattr(parent, 'close_terminal'):
                parent.close_terminal(self)
                break
            parent = parent.get_parent()

    def copy_clipboard(self):
        self.vte.copy_clipboard_format(Vte.Format.TEXT)

    def paste_clipboard(self):
        self.vte.paste_clipboard()

    def zoom_in(self):
        font = self.vte.get_font()
        desc = font.copy()
        size = desc.get_size() / Pango.SCALE
        desc.set_size(int((size + 1) * Pango.SCALE))
        self.vte.set_font(desc)

    def zoom_out(self):
        font = self.vte.get_font()
        desc = font.copy()
        size = desc.get_size() / Pango.SCALE
        if size > 6:
            desc.set_size(int((size - 1) * Pango.SCALE))
            self.vte.set_font(desc)

    def zoom_reset(self):
        font_family = self.config_manager.get('General', 'font_family', 'Monospace')
        font_size = self.config_manager.getint('General', 'font_size', 12)
        desc = Pango.FontDescription(f"{font_family} {font_size}")
        self.vte.set_font(desc)

    # Search Features
    def show_search(self):
        self.search_box.show_all()
        self.search_entry.grab_focus()

    def hide_search(self):
        self.search_box.hide()
        self.vte.search_set_regex(None, 0)
        self.vte.grab_focus()

    def _on_search_changed(self, entry):
        text = entry.get_text()
        if text:
            try:
                regex = Vte.Regex.new_for_search(text, len(text), GLib.RegexCompileFlags.CASELESS)
                self.vte.search_set_regex(regex, 0)
                self.vte.search_set_wrap_around(True)
                self.vte.search_find_previous()
            except Exception:
                pass
        else:
            self.vte.search_set_regex(None, 0)

    def _on_search_next(self, *args):
        self.vte.search_find_next()

    def _on_search_prev(self, *args):
        self.vte.search_find_previous()
