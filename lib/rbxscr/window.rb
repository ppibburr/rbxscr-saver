require 'gtk3'

class ScreenSaverWindow < Gtk::Window
  def initialize
    super

    embed
  end
  
  def embed ident = ENV['XSCREENSAVER_WINDOW']
    return if !ident || ident==''
    
    realize
    
    embed = Gdk::X11Window.new(Gdk::X11Display.default,ident.to_i(16)) rescue Gdk::X11Window.lookup_for_display(Gdk::X11Display.default,ident.to_i(16))
    
    `xdotool windowreparent #{window.xid} #{ident.to_i(16)}`

    x, y, width, height, depth = embed.geometry
   
    set_default_size width, height
  rescue => e
    p e  
  end
end 
