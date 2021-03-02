begin 
  Gtk
rescue
  require 'gtk3'
end

# Allows to embed a X11 handle into widget
module GtkX11Embed
  module Socket
    attr_accessor :plugged
  
    # @param [Integer] +xid+
    def take xid,x=0,y=0, display: Gdk::X11Display.default
      p window: window, xid: window.xid
      p embed:  (e=Gdk::X11Window.new(display,xid)), exid: e.xid
      take_window  e,x,y  
    end
    
    def take_window e ,x=0,y=0
      @plugged=e
      e.reparent window,x,y  
    end
    
    # Reparents Socket# from _+old+ to +new_parent+
    # +new_parent+ must respond to and have a suitable +#add(widget)+ method
    def swap old, new_parent
      plugged.hide

      old.remove self
      new_parent.add self
      
      realize
      
      take_window plugged 
      plugged.show    
      
      @parent = new_parent
    end    
  end
end
