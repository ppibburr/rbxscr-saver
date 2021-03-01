$: << File.join(d=File.dirname(__FILE__))
v=File.join(d,"..","..","vendor")

Dir.glob(File.join(v,"*","lib")).each do |f|
  $: << f
end

require 'gtk-glfw'
require 'gtk-x11-embed'

class ScreenSaver
  attr_reader :window
  def initialize w=nil
    @window = (w||Gtk::Window.new)

    window.fullscreen if ScreenSaver.fullscreen
    
    if window.size_request.index(-1)
      window.set_size_request 600,450 if ScreenSaver.demo
    end

    @window.extend GtkX11Embed::Plug

        
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
    @ins.window.show_all;
    
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
end
