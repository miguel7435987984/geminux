"""
Preferences Dialog for Geminux Terminal
Provides full UI to customize themes, colors, fonts, transparency, cursor, and shortcuts.
"""
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, Pango

def parse_rgba(hex_color, alpha=1.0):
    c = Gdk.RGBA()
    c.parse(hex_color)
    c.alpha = alpha
    return c

def rgba_to_hex(rgba):
    r = int(rgba.red * 255)
    g = int(rgba.green * 255)
    b = int(rgba.blue * 255)
    return f"#{r:02x}{g:02x}{b:02x}"

class PreferencesDialog(Gtk.Dialog):
    def __init__(self, parent, config_manager, on_apply_callback):
        super().__init__(
            title="Preferências do Geminux Terminal",
            transient_for=parent,
            flags=0
        )
        self.config_manager = config_manager
        self.on_apply_callback = on_apply_callback
        self.set_default_size(680, 520)
        self.set_modal(True)
        self.get_style_context().add_class('geminux-dialog')

        # Action buttons
        self.add_button("Fechar", Gtk.ResponseType.CLOSE)

        content_area = self.get_content_area()
        content_area.set_spacing(10)
        content_area.set_border_width(12)

        # Main layout with Stack & StackSwitcher
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        content_area.pack_start(main_box, True, True, 0)

        stack = Gtk.Stack()
        stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        stack.set_transition_duration(200)

        stack_switcher = Gtk.StackSwitcher()
        stack_switcher.set_stack(stack)
        stack_switcher.set_halign(Gtk.Align.CENTER)
        main_box.pack_start(stack_switcher, False, False, 0)

        # 1. Appearance Page (Themes, Colors, Transparency)
        stack.add_titled(self._create_appearance_page(), "appearance", "Aparência & Cores")

        # 2. Text & Font Page
        stack.add_titled(self._create_font_page(), "font", "Fonte & Cursor")

        # 3. Behavior & Shell Page
        stack.add_titled(self._create_behavior_page(), "behavior", "Shell & Comportamento")

        # 4. Shortcuts Page
        stack.add_titled(self._create_shortcuts_page(), "shortcuts", "Atalhos")

        main_box.pack_start(stack, True, True, 0)
        self.show_all()

    def _create_appearance_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        box.set_border_width(10)

        # Theme selection
        frame_theme = Gtk.Frame(label="Tema de Cores")
        grid_theme = Gtk.Grid()
        grid_theme.set_column_spacing(12)
        grid_theme.set_row_spacing(10)
        grid_theme.set_border_width(12)
        frame_theme.add(grid_theme)

        grid_theme.attach(Gtk.Label(label="Tema Predefinido:", halign=Gtk.Align.START), 0, 0, 1, 1)

        self.theme_combo = Gtk.ComboBoxText()
        themes = self.config_manager.get_theme_names()
        current_theme = self.config_manager.get('General', 'theme', 'Catppuccin Mocha')

        for idx, t in enumerate(themes):
            self.theme_combo.append_text(t)
            if t == current_theme:
                self.theme_combo.set_active(idx)

        self.theme_combo.connect('changed', self._on_theme_changed)
        grid_theme.attach(self.theme_combo, 1, 0, 1, 1)

        # Opacity slider
        grid_theme.attach(Gtk.Label(label="Opacidade / Transparência:", halign=Gtk.Align.START), 0, 1, 1, 1)
        current_opacity = self.config_manager.getfloat('General', 'opacity', 0.90)

        self.opacity_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0.20, 1.0, 0.05)
        self.opacity_scale.set_value(current_opacity)
        self.opacity_scale.set_hexpand(True)
        self.opacity_scale.set_value_pos(Gtk.PositionType.RIGHT)
        self.opacity_scale.connect('value-changed', self._on_opacity_changed)
        grid_theme.attach(self.opacity_scale, 1, 1, 1, 1)

        # Color Palette Preview & Custom Color Editor
        frame_palette = Gtk.Frame(label="Paleta ANSI (16 Cores)")
        palette_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        palette_box.set_border_width(12)
        frame_palette.add(palette_box)

        # Grid of 16 color buttons
        self.palette_buttons = []
        palette_grid = Gtk.Grid()
        palette_grid.set_column_spacing(8)
        palette_grid.set_row_spacing(8)
        palette_grid.set_halign(Gtk.Align.CENTER)

        colors = self.config_manager.get_theme_colors(current_theme)
        for i, hex_c in enumerate(colors['palette'][:16]):
            btn = Gtk.ColorButton()
            btn.set_rgba(parse_rgba(hex_c))
            btn.connect('color-set', self._on_palette_color_set, i)
            row = 0 if i < 8 else 1
            col = i % 8
            palette_grid.attach(btn, col, row, 1, 1)
            self.palette_buttons.append(btn)

        palette_box.pack_start(palette_grid, False, False, 0)

        # FG, BG, Cursor colors
        misc_colors_grid = Gtk.Grid()
        misc_colors_grid.set_column_spacing(12)
        misc_colors_grid.set_row_spacing(8)
        misc_colors_grid.set_border_width(6)

        misc_colors_grid.attach(Gtk.Label(label="Fundo (Background):", halign=Gtk.Align.START), 0, 0, 1, 1)
        self.btn_bg = Gtk.ColorButton()
        self.btn_bg.set_rgba(parse_rgba(colors['background']))
        self.btn_bg.connect('color-set', self._on_bg_color_set)
        misc_colors_grid.attach(self.btn_bg, 1, 0, 1, 1)

        misc_colors_grid.attach(Gtk.Label(label="Texto (Foreground):", halign=Gtk.Align.START), 2, 0, 1, 1)
        self.btn_fg = Gtk.ColorButton()
        self.btn_fg.set_rgba(parse_rgba(colors['foreground']))
        self.btn_fg.connect('color-set', self._on_fg_color_set)
        misc_colors_grid.attach(self.btn_fg, 3, 0, 1, 1)

        palette_box.pack_start(misc_colors_grid, False, False, 0)

        box.pack_start(frame_theme, False, False, 0)
        box.pack_start(frame_palette, False, False, 0)
        return box

    def _create_font_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        box.set_border_width(10)

        frame_font = Gtk.Frame(label="Tipografia")
        grid_font = Gtk.Grid()
        grid_font.set_column_spacing(12)
        grid_font.set_row_spacing(12)
        grid_font.set_border_width(12)
        frame_font.add(grid_font)

        # Font button
        grid_font.attach(Gtk.Label(label="Fonte do Terminal:", halign=Gtk.Align.START), 0, 0, 1, 1)
        cur_font_family = self.config_manager.get('General', 'font_family', 'Monospace')
        cur_font_size = self.config_manager.get('General', 'font_size', '12')

        self.font_btn = Gtk.FontButton()
        self.font_btn.set_font(f"{cur_font_family} {cur_font_size}")
        self.font_btn.set_use_font(True)
        self.font_btn.set_use_size(True)
        self.font_btn.connect('font-set', self._on_font_set)
        grid_font.attach(self.font_btn, 1, 0, 1, 1)

        # Allow bold checkbox
        self.check_bold = Gtk.CheckButton(label="Permitir texto em negrito (Bold)")
        self.check_bold.set_active(self.config_manager.getboolean('General', 'allow_bold', True))
        self.check_bold.connect('toggled', self._on_bold_toggled)
        grid_font.attach(self.check_bold, 0, 1, 2, 1)

        frame_cursor = Gtk.Frame(label="Formato & Comportamento do Cursor")
        grid_cursor = Gtk.Grid()
        grid_cursor.set_column_spacing(12)
        grid_cursor.set_row_spacing(12)
        grid_cursor.set_border_width(12)
        frame_cursor.add(grid_cursor)

        # Cursor shape
        grid_cursor.attach(Gtk.Label(label="Formato do Cursor:", halign=Gtk.Align.START), 0, 0, 1, 1)
        self.combo_cursor_shape = Gtk.ComboBoxText()
        shapes = [("Bloco (Block)", "BLOCK"), ("Barra Vertical (I-Beam)", "IBEAM"), ("Sublinhado (Underline)", "UNDERLINE")]
        cur_shape = self.config_manager.get('General', 'cursor_shape', 'BLOCK').upper()

        for idx, (label, val) in enumerate(shapes):
            self.combo_cursor_shape.append(val, label)
            if val == cur_shape:
                self.combo_cursor_shape.set_active(idx)
        self.combo_cursor_shape.connect('changed', self._on_cursor_shape_changed)
        grid_cursor.attach(self.combo_cursor_shape, 1, 0, 1, 1)

        # Cursor blink
        grid_cursor.attach(Gtk.Label(label="Piscar do Cursor:", halign=Gtk.Align.START), 0, 1, 1, 1)
        self.combo_cursor_blink = Gtk.ComboBoxText()
        blinks = [("Padrão do Sistema", "SYSTEM"), ("Sempre Piscar (Ativado)", "ON"), ("Fixo (Desativado)", "OFF")]
        cur_blink = self.config_manager.get('General', 'cursor_blink', 'SYSTEM').upper()

        for idx, (label, val) in enumerate(blinks):
            self.combo_cursor_blink.append(val, label)
            if val == cur_blink:
                self.combo_cursor_blink.set_active(idx)
        self.combo_cursor_blink.connect('changed', self._on_cursor_blink_changed)
        grid_cursor.attach(self.combo_cursor_blink, 1, 1, 1, 1)

        box.pack_start(frame_font, False, False, 0)
        box.pack_start(frame_cursor, False, False, 0)
        return box

    def _create_behavior_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        box.set_border_width(10)

        # Shell Options
        frame_shell = Gtk.Frame(label="Comando & Shell")
        grid_shell = Gtk.Grid()
        grid_shell.set_column_spacing(12)
        grid_shell.set_row_spacing(10)
        grid_shell.set_border_width(12)
        frame_shell.add(grid_shell)

        grid_shell.attach(Gtk.Label(label="Shell Personalizado (/bin/bash, /bin/zsh, fish):", halign=Gtk.Align.START), 0, 0, 1, 1)
        self.entry_shell = Gtk.Entry()
        self.entry_shell.set_text(self.config_manager.get('General', 'custom_shell', ''))
        self.entry_shell.set_placeholder_text("Deixe vazio para usar shell padrão")
        self.entry_shell.connect('changed', lambda e: self._save_setting('General', 'custom_shell', e.get_text()))
        grid_shell.attach(self.entry_shell, 1, 0, 1, 1)

        # Scrollback lines
        grid_shell.attach(Gtk.Label(label="Linhas de Rolagem (Histórico):", halign=Gtk.Align.START), 0, 1, 1, 1)
        self.spin_scroll = Gtk.SpinButton.new_with_range(500, 100000, 500)
        self.spin_scroll.set_value(self.config_manager.getint('General', 'scrollback_lines', 10000))
        self.spin_scroll.connect('value-changed', lambda s: self._save_setting('General', 'scrollback_lines', int(s.get_value())))
        grid_shell.attach(self.spin_scroll, 1, 1, 1, 1)

        # Checkboxes
        frame_other = Gtk.Frame(label="Opções Adicionais")
        box_other = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=8)
        box_other.set_border_width(12)
        frame_other.add(box_other)

        self.check_bell = Gtk.CheckButton(label="Alarme Sonoro (Audible Bell)")
        self.check_bell.set_active(self.config_manager.getboolean('General', 'audible_bell', False))
        self.check_bell.connect('toggled', lambda c: self._save_setting('General', 'audible_bell', c.get_active()))
        box_other.pack_start(self.check_bell, False, False, 0)

        self.check_scroll_out = Gtk.CheckButton(label="Rolar para o final ao receber saída (Scroll on Output)")
        self.check_scroll_out.set_active(self.config_manager.getboolean('General', 'scroll_on_output', False))
        self.check_scroll_out.connect('toggled', lambda c: self._save_setting('General', 'scroll_on_output', c.get_active()))
        box_other.pack_start(self.check_scroll_out, False, False, 0)

        self.check_scroll_key = Gtk.CheckButton(label="Rolar ao pressionar tecla (Scroll on Keystroke)")
        self.check_scroll_key.set_active(self.config_manager.getboolean('General', 'scroll_on_keystroke', True))
        self.check_scroll_key.connect('toggled', lambda c: self._save_setting('General', 'scroll_on_keystroke', c.get_active()))
        box_other.pack_start(self.check_scroll_key, False, False, 0)

        box.pack_start(frame_shell, False, False, 0)
        box.pack_start(frame_other, False, False, 0)
        return box

    def _create_shortcuts_page(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        box.set_border_width(10)

        label = Gtk.Label(label="<b>Atalhos de Teclado Suportados:</b>", use_markup=True, halign=Gtk.Align.START)
        box.pack_start(label, False, False, 0)

        shortcuts = [
            ("Ctrl + Shift + T", "Nova Aba"),
            ("Ctrl + Shift + W", "Fechar Aba / Divisão Atual"),
            ("Ctrl + Shift + E", "Dividir Terminal Verticalmente"),
            ("Ctrl + Shift + O", "Dividir Terminal Horizontalmente"),
            ("Ctrl + Shift + C", "Copiar Texto"),
            ("Ctrl + Shift + V", "Colar Texto"),
            ("Ctrl + Shift + F", "Pesquisar no Terminal"),
            ("Ctrl + Tab / Ctrl + PageDown", "Próxima Aba"),
            ("Ctrl + Shift + Tab / Ctrl + PageUp", "Aba Anterior"),
            ("Ctrl + Mais (+)", "Aumentar Zoom / Fonte"),
            ("Ctrl + Menos (-)", "Diminuir Zoom / Fonte"),
            ("Ctrl + 0", "Resetar Tamanho da Fonte"),
            ("F11", "Alternar Modo Tela Cheia"),
            ("Ctrl + Shift + P", "Abrir Preferências e Configurações"),
            ("Ctrl + Clique", "Abrir Link / URL no Navegador")
        ]

        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)

        listbox = Gtk.ListBox()
        listbox.set_selection_mode(Gtk.SelectionMode.NONE)

        for key, desc in shortcuts:
            row = Gtk.ListBoxRow()
            hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=16)
            hbox.set_border_width(8)

            lbl_desc = Gtk.Label(label=desc, halign=Gtk.Align.START, hexpand=True)
            lbl_key = Gtk.Label(label=f"<tt><b>{key}</b></tt>", use_markup=True, halign=Gtk.Align.END)

            hbox.pack_start(lbl_desc, True, True, 0)
            hbox.pack_start(lbl_key, False, False, 0)
            row.add(hbox)
            listbox.add(row)

        scrolled.add(listbox)
        box.pack_start(scrolled, True, True, 0)
        return box

    def _save_setting(self, section, key, value):
        self.config_manager.set(section, key, value)
        self.config_manager.save()
        if self.on_apply_callback:
            self.on_apply_callback()

    def _on_theme_changed(self, combo):
        theme_name = combo.get_active_text()
        if theme_name:
            self.config_manager.set('General', 'theme', theme_name)
            self.config_manager.save()
            colors = self.config_manager.get_theme_colors(theme_name)

            # Update preview buttons
            for i, hex_c in enumerate(colors['palette'][:16]):
                if i < len(self.palette_buttons):
                    self.palette_buttons[i].set_rgba(parse_rgba(hex_c))
            self.btn_bg.set_rgba(parse_rgba(colors['background']))
            self.btn_fg.set_rgba(parse_rgba(colors['foreground']))

            if self.on_apply_callback:
                self.on_apply_callback()

    def _on_opacity_changed(self, scale):
        val = scale.get_value()
        self._save_setting('General', 'opacity', f"{val:.2f}")

    def _on_font_set(self, btn):
        font_desc = Pango.FontDescription(btn.get_font())
        family = font_desc.get_family()
        size = font_desc.get_size() // Pango.SCALE
        self.config_manager.set('General', 'font_family', family)
        self.config_manager.set('General', 'font_size', str(size))
        self.config_manager.save()
        if self.on_apply_callback:
            self.on_apply_callback()

    def _on_bold_toggled(self, check):
        self._save_setting('General', 'allow_bold', check.get_active())

    def _on_cursor_shape_changed(self, combo):
        shape = combo.get_active_id()
        if shape:
            self._save_setting('General', 'cursor_shape', shape)

    def _on_cursor_blink_changed(self, combo):
        blink = combo.get_active_id()
        if blink:
            self._save_setting('General', 'cursor_blink', blink)

    def _on_palette_color_set(self, btn, index):
        theme_name = self.config_manager.get('General', 'theme', 'Custom')
        colors = self.config_manager.get_theme_colors(theme_name)
        new_hex = rgba_to_hex(btn.get_rgba())
        palette = colors['palette']
        if index < len(palette):
            palette[index] = new_hex
        self.config_manager.save_custom_theme(
            theme_name if theme_name != 'Catppuccin Mocha' else 'Custom',
            colors['background'], colors['foreground'], colors['cursor'], colors['cursor_foreground'], palette
        )
        if self.on_apply_callback:
            self.on_apply_callback()

    def _on_bg_color_set(self, btn):
        theme_name = self.config_manager.get('General', 'theme', 'Custom')
        colors = self.config_manager.get_theme_colors(theme_name)
        new_hex = rgba_to_hex(btn.get_rgba())
        self.config_manager.save_custom_theme(
            theme_name if theme_name != 'Catppuccin Mocha' else 'Custom',
            new_hex, colors['foreground'], colors['cursor'], colors['cursor_foreground'], colors['palette']
        )
        if self.on_apply_callback:
            self.on_apply_callback()

    def _on_fg_color_set(self, btn):
        theme_name = self.config_manager.get('General', 'theme', 'Custom')
        colors = self.config_manager.get_theme_colors(theme_name)
        new_hex = rgba_to_hex(btn.get_rgba())
        self.config_manager.save_custom_theme(
            theme_name if theme_name != 'Catppuccin Mocha' else 'Custom',
            colors['background'], new_hex, colors['cursor'], colors['cursor_foreground'], colors['palette']
        )
        if self.on_apply_callback:
            self.on_apply_callback()
