module GtkX11Embed
  module Plug
    def plug xid, display: Gdk::X11Display.default
      window.reparent(@_gdkwin||=Gdk::X11Window.new(display, xid),0,0)
    end

    def plug_geometry xid, display: Gdk::X11Display.default
      (@_gdkwin||=Gdk::X11Window.new(display, xid)).geometry
    end
  end
end
