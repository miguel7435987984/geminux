"""
Application entrypoint for Geminux Terminal
"""
import sys
import os
import signal
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gio, GLib

from .config import ConfigManager
from .main_window import MainWindow

class GeminuxTerminalApp(Gtk.Application):
    def __init__(self):
        super().__init__(
            application_id="org.geminux.terminal",
            flags=Gio.ApplicationFlags.FLAGS_NONE
        )
        self.config_manager = None
        self.window = None

    def do_startup(self):
        Gtk.Application.do_startup(self)
        GLib.set_application_name("Geminux Terminal")
        GLib.set_prgname("geminux-terminal")

    def do_activate(self):
        if not self.window:
            self.config_manager = ConfigManager()
            self.window = MainWindow(self, self.config_manager)
        self.window.present()

def main():
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    app = GeminuxTerminalApp()
    return app.run(sys.argv)

if __name__ == '__main__':
    sys.exit(main())
