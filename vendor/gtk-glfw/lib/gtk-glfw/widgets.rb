# widgets.rb
$: << File.join(File.dirname(__FILE__),"..")

require "gtk-glfw"
require "gtk-glfw/canvas"

begin
  Gtk
rescue
  require 'gtk3'
end

module GtkGLFW
  # Embedable widget to use in a Gtk::Container#
  # glXContext is rendered to [Gdk::Window] GtkGLFW::Socket#.window
  class Socket < Gtk::Socket
    include Widget
    
    # @option [Gtk::Widget] parent if given will call `parent.add(self)`
    def initialize parent: nil
      super()
      
      parent.add self if parent
    end
    
    # Override GtkX11Embed::Socket#swap( old, new )
    def swap new_parent, from=parent
      super from, new_parent    
    end
    
    # Switches to fullscreen mode (calls Socket#swap(new_parent = w = Gtk::Window.new))
    def fullscreen &b
      p = parent
      
      w=Gtk::Window.new
      w.extend GtkX11Embed::Socket

      w.fullscreen
      w.realize
      
      swap w
      
      w.signal_connect "delete-event" do
        swap p
        false
      end
      
      plugged.hide
      w.show
      
      GLib::Idle.add do
        plugged.resize w.allocation.width, w.allocation.height
        plugged.show
        false 
      end
      
      b.call w if b
      
      w
    end    
  end
  
  # A TopLevel Window
  # glXContext is rendered to [Gdk::Window] Gtk::Window#.window
  # meant to not have any children.
  #
  # @see [GtkGLFW::Socket] for embedding as a widget in a window
  class Window < Gtk::Window
    include Widget
    
    def self.run(title: 'GtkGLFW | OpenGL For RubyGtk', &b)
      w=new(&b)
      w.title = title      
      w.show_all

      w.signal_connect "delete-event" do
        Gtk.main_quit
      end
      
      Gtk.main
    end
  end
end

if __FILE__ == $0
  require "gtk-glfw"

  demo = proc do |gflw_window|
	  width_ptr = ' ' * 8
	  height_ptr = ' ' * 8
	  glfwGetFramebufferSize(gflw_window, width_ptr, height_ptr)
	  width = width_ptr.unpack('L')[0]
	  height = height_ptr.unpack('L')[0]
	  ratio = width.to_f / height.to_f

	  glViewport(0, 0, width, height)
	  glClear(GL_COLOR_BUFFER_BIT)
	  glMatrixMode(GL_PROJECTION)
	  glLoadIdentity()
	  glOrtho(-ratio, ratio, -1.0, 1.0, 1.0, -1.0)
	  glMatrixMode(GL_MODELVIEW)

	  glLoadIdentity()
	  glRotatef(glfwGetTime() * 225.0, 0.0, 0.0, 1.0)

	  glBegin(GL_TRIANGLES)
	  glColor3f(1.0, 0.0, 0.0)
	  glVertex3f(-0.6, -0.4, 0.0)
	  glColor3f(0.0, 1.0, 0.0)
	  glVertex3f(0.6, -0.4, 0.0)
	  glColor3f(0.0, 0.0, 1.0)
	  glVertex3f(0.0, 0.6, 0.0)
	  glEnd()
	end

  if ARGV[0] == 'socket'
	w=Gtk::Window.new
	w.resize 400,400
	w.add box=Gtk::Box.new(:vertical)
	
	box.pack_start(button=Gtk::Button.new, false,false,0)
	box.pack_start(bin=Gtk::Frame.new,true,true,0)
	
	g = GtkGLFW::Socket.new(parent: bin, &demo)	
	button.label = "Fullscreen"

	button.signal_connect 'clicked' do
	  g.fullscreen do |f|
	    f.signal_connect 'key-press-event' do
          f.close
        end
	  end
	end  
	  
	w.show_all
	
	
	w.signal_connect "delete-event" do
	  Gtk.main_quit
	end
	
	Gtk.main  
	
  elsif ARGV[0] == 'window'
	GtkGLFW::Window.run(&demo)
  end
end
