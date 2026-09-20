"""
Main Window for Geminux Terminal
Manages HeaderBar, Tabs, Split Panes, Global Keybindings and CSS Theming
"""
import os
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Vte', '2.91')
from gi.repository import Gtk, Gdk, GLib, Pango
import cairo

from .terminal import TerminalWidget
from .prefs_dialog import PreferencesDialog
from .theme_helper import generate_css

class MainWindow(Gtk.ApplicationWindow):
    def __init__(self, app, config_manager):
        super().__init__(application=app, title="Geminux Terminal")
        self.app = app
        self.config_manager = config_manager
        self.is_fullscreen = False

        # Configure Window
        self.set_default_size(
            self.config_manager.getint('General', 'window_width', 950),
            self.config_manager.getint('General', 'window_height', 580)
        )
        self.get_style_context().add_class('geminux-window')

        # Enable RGBA visual for true transparency and glassmorphism
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual and screen.is_composited():
            self.set_visual(visual)
        self.set_app_paintable(True)
        self.connect('draw', self._on_draw)

        # Style provider
        self.css_provider = Gtk.CssProvider()
        Gtk.StyleContext.add_provider_for_screen(
            screen, self.css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # HeaderBar (Modern Client Side Decorations)
        self._setup_headerbar()

        # Main Layout Container
        self.main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        self.add(self.main_box)

        # Notebook for Tabs
        self.notebook = Gtk.Notebook()
        self.notebook.get_style_context().add_class('geminux-notebook')
        self.notebook.set_scrollable(True)
        self.notebook.connect('switch-page', self._on_tab_switched)
        self.notebook.connect('page-removed', self._on_page_removed)
        self.main_box.pack_start(self.notebook, True, True, 0)

        # Keybindings
        self.connect('key-press-event', self._on_key_press)
        self.connect('delete-event', self._on_delete_event)

        # Initialize UI Theme & First Tab
        self.reload_css()
        self.new_tab()
        self.show_all()

    def _on_draw(self, widget, cr):
        # Allow translucent background painting
        theme_name = self.config_manager.get('General', 'theme', 'Catppuccin Mocha')
        colors = self.config_manager.get_theme_colors(theme_name)
        opacity = self.config_manager.getfloat('General', 'opacity', 0.90)

        bg = colors['background']
        r, g, b = 30/255.0, 30/255.0, 46/255.0
        if bg.startswith('#') and len(bg) == 7:
            r = int(bg[1:3], 16) / 255.0
            g = int(bg[3:5], 16) / 255.0
            b = int(bg[5:7], 16) / 255.0

        cr.set_source_rgba(r, g, b, opacity)
        cr.set_operator(cairo.OPERATOR_SOURCE)
        cr.paint()
        return False

    def reload_css(self):
        theme_name = self.config_manager.get('General', 'theme', 'Catppuccin Mocha')
        colors = self.config_manager.get_theme_colors(theme_name)
        opacity = self.config_manager.getfloat('General', 'opacity', 0.90)
        font_family = self.config_manager.get('General', 'font_family', 'Monospace')
        font_size = self.config_manager.getint('General', 'font_size', 12)

        css_data = generate_css(colors, opacity, font_family, font_size)
        try:
            self.css_provider.load_from_data(css_data.encode('utf-8'))
        except Exception as e:
            print(f"Erro ao carregar CSS: {e}")

        # Update all active terminals
        for term in self.get_all_terminals():
            term.apply_config()
        self.queue_draw()

    def _setup_headerbar(self):
        self.headerbar = Gtk.HeaderBar()
        self.headerbar.set_show_close_button(True)
        self.headerbar.set_title("Geminux Terminal")
        self.headerbar.get_style_context().add_class('geminux-headerbar')
        self.set_titlebar(self.headerbar)

        # Left controls: New Tab Button
        btn_new_tab = Gtk.Button.new_from_icon_name("tab-new-symbolic", Gtk.IconSize.BUTTON)
        btn_new_tab.set_tooltip_text("Nova Aba (Ctrl+Shift+T)")
        btn_new_tab.connect('clicked', lambda b: self.new_tab())
        self.headerbar.pack_start(btn_new_tab)

        # Split Buttons
        btn_split_v = Gtk.Button.new_from_icon_name("view-paged-symbolic", Gtk.IconSize.BUTTON)
        btn_split_v.set_tooltip_text("Dividir Vertical (Ctrl+Shift+E)")
        btn_split_v.connect('clicked', lambda b: self.split_active_terminal('vertical'))
        self.headerbar.pack_start(btn_split_v)

        btn_split_h = Gtk.Button.new_from_icon_name("view-dual-symbolic", Gtk.IconSize.BUTTON)
        btn_split_h.set_tooltip_text("Dividir Horizontal (Ctrl+Shift+O)")
        btn_split_h.connect('clicked', lambda b: self.split_active_terminal('horizontal'))
        self.headerbar.pack_start(btn_split_h)

        # Right controls: Search, Preferences, Menu
        btn_search = Gtk.Button.new_from_icon_name("edit-find-symbolic", Gtk.IconSize.BUTTON)
        btn_search.set_tooltip_text("Buscar (Ctrl+Shift+F)")
        btn_search.connect('clicked', lambda b: self.show_search_active_terminal())
        self.headerbar.pack_end(btn_search)

        btn_prefs = Gtk.Button.new_from_icon_name("preferences-system-symbolic", Gtk.IconSize.BUTTON)
        btn_prefs.set_tooltip_text("Preferências & Cores (Ctrl+Shift+P)")
        btn_prefs.connect('clicked', lambda b: self.open_preferences())
        self.headerbar.pack_end(btn_prefs)

    def new_tab(self, cwd=None):
        terminal = TerminalWidget(self.config_manager, cwd=cwd)
        tab_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)

        tab_label = Gtk.Label(label="Terminal")
        tab_box.pack_start(tab_label, True, True, 0)

        btn_close = Gtk.Button.new_from_icon_name("window-close-symbolic", Gtk.IconSize.MENU)
        btn_close.set_relief(Gtk.ReliefStyle.NONE)
        btn_close.connect('clicked', lambda b: self.close_tab_containing(terminal))
        tab_box.pack_start(btn_close, False, False, 0)
        tab_box.show_all()

        page_num = self.notebook.append_page(terminal, tab_box)
        self.notebook.set_tab_reorderable(terminal, True)
        self.notebook.show_all()
        self.notebook.set_current_page(page_num)
        terminal.vte.grab_focus()

    def get_active_terminal(self):
        page_num = self.notebook.get_current_page()
        if page_num < 0:
            return None
        page = self.notebook.get_nth_page(page_num)
        return self._find_focused_or_first_terminal(page)

    def _find_focused_or_first_terminal(self, widget):
        if isinstance(widget, TerminalWidget):
            return widget
        if isinstance(widget, Gtk.Paned):
            child1 = self._find_focused_or_first_terminal(widget.get_child1())
            child2 = self._find_focused_or_first_terminal(widget.get_child2())
            if child1 and child1.vte.has_focus():
                return child1
            if child2 and child2.vte.has_focus():
                return child2
            return child1 or child2
        if isinstance(widget, Gtk.Container):
            for child in widget.get_children():
                t = self._find_focused_or_first_terminal(child)
                if t:
                    return t
        return None

    def get_all_terminals(self):
        terminals = []
        for i in range(self.notebook.get_n_pages()):
            page = self.notebook.get_nth_page(i)
            self._collect_terminals(page, terminals)
        return terminals

    def _collect_terminals(self, widget, terminals):
        if isinstance(widget, TerminalWidget):
            terminals.append(widget)
        elif isinstance(widget, Gtk.Container):
            for child in widget.get_children():
                self._collect_terminals(child, terminals)

    def split_terminal(self, target_terminal, direction='vertical'):
        parent = target_terminal.get_parent()
        if not parent:
            return

        new_terminal = TerminalWidget(self.config_manager, cwd=target_terminal.cwd)

        # Create Paned container
        paned = Gtk.Paned(orientation=Gtk.Orientation.VERTICAL if direction == 'horizontal' else Gtk.Orientation.HORIZONTAL)

        if isinstance(parent, Gtk.Notebook):
            page_num = parent.page_num(target_terminal)
            tab_label = parent.get_tab_label(target_terminal)
            parent.remove(target_terminal)
            paned.pack1(target_terminal, True, False)
            paned.pack2(new_terminal, True, False)
            parent.insert_page(paned, tab_label, page_num)
            parent.set_tab_reorderable(paned, True)
        elif isinstance(parent, Gtk.Paned):
            is_child1 = (parent.get_child1() == target_terminal)
            parent.remove(target_terminal)
            paned.pack1(target_terminal, True, False)
            paned.pack2(new_terminal, True, False)
            if is_child1:
                parent.pack1(paned, True, False)
            else:
                parent.pack2(paned, True, False)

        self.show_all()
        new_terminal.vte.grab_focus()

    def split_active_terminal(self, direction='vertical'):
        active = self.get_active_terminal()
        if active:
            self.split_terminal(active, direction)

    def close_terminal(self, terminal):
        parent = terminal.get_parent()
        if not parent:
            return

        if isinstance(parent, Gtk.Notebook):
            # It's the only terminal in the tab
            page_num = parent.page_num(terminal)
            parent.remove_page(page_num)
        elif isinstance(parent, Gtk.Paned):
            # Replace Paned with the other sibling widget
            grandparent = parent.get_parent()
            sibling = parent.get_child2() if parent.get_child1() == terminal else parent.get_child1()
            parent.remove(terminal)
            parent.remove(sibling)

            if isinstance(grandparent, Gtk.Notebook):
                page_num = grandparent.page_num(parent)
                tab_label = grandparent.get_tab_label(parent)
                grandparent.remove_page(page_num)
                grandparent.insert_page(sibling, tab_label, page_num)
                grandparent.set_tab_reorderable(sibling, True)
            elif isinstance(grandparent, Gtk.Paned):
                is_child1 = (grandparent.get_child1() == parent)
                grandparent.remove(parent)
                if is_child1:
                    grandparent.pack1(sibling, True, False)
                else:
                    grandparent.pack2(sibling, True, False)

        if self.notebook.get_n_pages() == 0:
            self.close()

    def close_tab_containing(self, widget):
        # Find which tab page contains this widget
        for i in range(self.notebook.get_n_pages()):
            page = self.notebook.get_nth_page(i)
            if page == widget or self._is_descendant(widget, page):
                self.notebook.remove_page(i)
                break
        if self.notebook.get_n_pages() == 0:
            self.close()

    def _is_descendant(self, target, ancestor):
        if not isinstance(ancestor, Gtk.Container):
            return False
        for child in ancestor.get_children():
            if child == target or self._is_descendant(target, child):
                return True
        return False

    def update_tab_title(self, terminal, title):
        # Update HeaderBar and Tab Label
        self.headerbar.set_subtitle(title)
        for i in range(self.notebook.get_n_pages()):
            page = self.notebook.get_nth_page(i)
            if page == terminal or self._is_descendant(terminal, page):
                tab_box = self.notebook.get_tab_label(page)
                if isinstance(tab_box, Gtk.Box):
                    lbl = tab_box.get_children()[0]
                    short_title = title.split()[-1] if '/' in title else title
                    lbl.set_text(short_title[:20])
                break

    def _on_tab_switched(self, notebook, page, page_num):
        term = self._find_focused_or_first_terminal(page)
        if term:
            self.headerbar.set_subtitle(term.get_current_title())
            term.vte.grab_focus()

    def _on_page_removed(self, notebook, child, page_num):
        if notebook.get_n_pages() == 0:
            self.close()

    def show_search_active_terminal(self):
        active = self.get_active_terminal()
        if active:
            active.show_search()

    def open_preferences(self):
        dlg = PreferencesDialog(self, self.config_manager, self.reload_css)
        dlg.run()
        dlg.destroy()

    def toggle_fullscreen(self):
        if self.is_fullscreen:
            self.unfullscreen()
            self.is_fullscreen = False
        else:
            self.fullscreen()
            self.is_fullscreen = True

    def _on_key_press(self, widget, event):
        state = event.state & Gtk.accelerator_get_default_mod_mask()
        ctrl = bool(state & Gdk.ModifierType.CONTROL_MASK)
        shift = bool(state & Gdk.ModifierType.SHIFT_MASK)
        keyval = event.keyval

        # Ctrl+Shift Shortcuts
        if ctrl and shift:
            if keyval in (Gdk.KEY_T, Gdk.KEY_t):
                self.new_tab()
                return True
            elif keyval in (Gdk.KEY_W, Gdk.KEY_w):
                active = self.get_active_terminal()
                if active:
                    self.close_terminal(active)
                return True
            elif keyval in (Gdk.KEY_E, Gdk.KEY_e):
                self.split_active_terminal('vertical')
                return True
            elif keyval in (Gdk.KEY_O, Gdk.KEY_o):
                self.split_active_terminal('horizontal')
                return True
            elif keyval in (Gdk.KEY_F, Gdk.KEY_f):
                self.show_search_active_terminal()
                return True
            elif keyval in (Gdk.KEY_C, Gdk.KEY_c):
                active = self.get_active_terminal()
                if active:
                    active.copy_clipboard()
                return True
            elif keyval in (Gdk.KEY_V, Gdk.KEY_v):
                active = self.get_active_terminal()
                if active:
                    active.paste_clipboard()
                return True
            elif keyval in (Gdk.KEY_P, Gdk.KEY_p):
                self.open_preferences()
                return True
            elif keyval == Gdk.KEY_ISO_Left_Tab:
                # Ctrl+Shift+Tab
                cur = self.notebook.get_current_page()
                self.notebook.set_current_page((cur - 1) % self.notebook.get_n_pages())
                return True

        # Ctrl Shortcuts (Zoom / Tab switch)
        if ctrl and not shift:
            if keyval in (Gdk.KEY_plus, Gdk.KEY_equal, Gdk.KEY_KP_Add):
                active = self.get_active_terminal()
                if active:
                    active.zoom_in()
                return True
            elif keyval in (Gdk.KEY_minus, Gdk.KEY_underscore, Gdk.KEY_KP_Subtract):
                active = self.get_active_terminal()
                if active:
                    active.zoom_out()
                return True
            elif keyval in (Gdk.KEY_0, Gdk.KEY_KP_0):
                active = self.get_active_terminal()
                if active:
                    active.zoom_reset()
                return True
            elif keyval == Gdk.KEY_Tab or keyval == Gdk.KEY_Page_Down:
                cur = self.notebook.get_current_page()
                self.notebook.set_current_page((cur + 1) % self.notebook.get_n_pages())
                return True
            elif keyval == Gdk.KEY_Page_Up:
                cur = self.notebook.get_current_page()
                self.notebook.set_current_page((cur - 1) % self.notebook.get_n_pages())
                return True

        # F11 Fullscreen
        if keyval == Gdk.KEY_F11:
            self.toggle_fullscreen()
            return True

        # Escape closes search if open
        if keyval == Gdk.KEY_Escape:
            active = self.get_active_terminal()
            if active and active.search_box.is_visible():
                active.hide_search()
                return True

        return False

    def _on_delete_event(self, widget, event):
        # Save current window geometry
        width, height = self.get_size()
        self.config_manager.set('General', 'window_width', width)
        self.config_manager.set('General', 'window_height', height)
        self.config_manager.save()
        return False
