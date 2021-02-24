require 'rbxscr/window'

window = ScreenSaverWindow.new

window.add l=Gtk::Label.new

l.text = __FILE__

window.show_all

Gtk.main
