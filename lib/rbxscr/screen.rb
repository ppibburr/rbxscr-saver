$: << File.join(File.dirname(__FILE__))

require 'gtk3'

class ScreenSaver
  attr_reader :window
  def initialize w=nil
    @window = (w||Gtk::Window.new)
    if window.size_request.index(-1)
      window.set_size_request 600,450 if ScreenSaver.demo
    end

    @window.extend GtkX11Plug
    window.fullscreen if ScreenSaver.fullscreen
        
    window.signal_connect "realize" do
      x,y,h,w = window.plug_geometry(x=ENV["XSCREENSAVER_WINDOW"].to_i(16)) if !ScreenSaver.demo
      window.set_size_request(h,w) if !ScreenSaver.demo
      window.plug x if !ScreenSaver.demo
    end
  end
    
  def self.run(window=nil, &b)
    @ins=new(window)
    @ins.window.signal_connect "button-press-event" do Gtk.main_quit end
    @ins.window.signal_connect "key-press-event"    do Gtk.main_quit end   
    
    b.call(@ins, @ins.window) if b
    @ins.window.show_all
    Gtk::main
  end 
  
  class Preferences < Gtk::Window
    def initialize
      self.title = 'Ruby XScreenSaver |  Preferences'
      set_default_size 600,800
    end
  end
  
  def self.preferences
    Preferences.new.show_all
    Gtk.main
  end
  
  module GtkX11Plug
    def plug xid, display: Gdk::X11Display.default
      window.reparent(@_gdkwin||=Gdk::X11Window.new(display, xid),0,0)
    end

    def plug_geometry xid, display: Gdk::X11Display.default
      (@_gdkwin||=Gdk::X11Window.new(display, xid)).geometry
    end
  end
end
