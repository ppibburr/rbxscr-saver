#
# For more samples, visit https://github.com/vaiorabbit/ruby-opengl/tree/master/sample .
#
# Ref.: /glfw-3.0.1/examples/simple.c
#
require 'opengl'
require 'glfw'
require 'ffi'

module GLFWX11Window
  extend FFI::Library
  ffi_lib 'glfw'
  attach_function :glfwGetX11Window, [:pointer], :int
end

include GLFWX11Window
include OpenGL
include GLFW

# Allows to embed a X11 handle into widget
module GtkX11Socket
  
  # @param [Integer] +xid+
  def take xid,x=0,y=0, display: Gdk::X11Display.default
    p window: window, xid: window.xid
    p embed:  (e=Gdk::X11Window.new(display,xid)), exid: e.xid
    e.reparent window,x,y  
  end
end


module GtkGLFW
  # Widget embedding a glfwWindow
  module Drawable
    OpenGL.load_lib()
    GLFW.load_lib()  
    glfwInit()
    
    include GtkX11Socket
  
    attr_reader :glfw_window
    attr_reader :monitor
    
    # @param [:primary|nil] +m+
    def monitor= m
      case m
      when :primary
        @monitor = glfwGetPrimaryMonitor()
      else
        m
      end
    end

    def initialize *o,&b
      super *o
      
      at_exit do
        glfwTerminate()
      end
      
      run &b
    end
    
    # @return [Integer] xid of the embedded glfwWindow
    def xid
      ptr = FFI::Pointer.new(glfw_window.to_i)
      xid=glfwGetX11Window(ptr)
    end
    
    # @option [:primary|nil] +monitor+
    def create monitor: @monitor
      y2=allocation.height
      x2=allocation.width
      window || realize  
      
      @glfw_window = glfwCreateWindow(x2,y2, "No See Me", monitor, nil )
      glfwMakeContextCurrent(glfw_window)
   
   
      GLib::Timeout.add(500) do
        take xid 
        
        @go = true
        false
      end        
    end
    
    # Setup and run the loop calling &b
    def run &b
      signal_connect "notify" do |*o|
        p o
      end
    
      signal_connect "draw" do
        unless glfw_window
          create
          queue_draw
          next
        end
        
        unless @go
          queue_draw
          next
        end
        
        b.call glfw_window

        glfwSwapBuffers( glfw_window )
        glfwPollEvents()        
        queue_draw
      end
    end
    
    def glfw_ready?
      @go
    end
  end

  # a Canvas Widget meant to placed in a Gtk::Window or child of
  class SocketCanvas < Gtk::Socket
    include Drawable
    
    # @option [Gtk::Widget] parent if given will call `parent.add(self)`
    def initialize parent: nil
      super()
      
      parent.add self if parent
    end
  end

  # a Window meant to not have any children as the glfwWindow is embedded into it
  class WindowCanvas < Gtk::Window
    include Drawable
  
    # @param [:primary|nil] +monitor+
    def initialize monitor: nil
      super()
      self.monitor = monitor if monitor      
      
    end
  
    # sets fullscreen with @monitor or :primary
    def fullscreen
      super
      self.monitor = (@monitor ||= :primary)
    end
  end
end

class GLFWWindow
  attr_reader :glfw_window
  def initialize monitor: nil, &b
    self.monitor = monitor
    create
    
    GLib::Idle.add do
      loop do
        b.call glfw_window
        glfwSwapBuffers( glfw_window )
        glfwPollEvents()
      end
      false
    end
    
    Gtk.main   
  end
 
  # @param [:primary|nil] +m+
  def monitor= m
    case m
    when :primary
      @monitor = glfwGetPrimaryMonitor()
    else
      m
    end
  end  
  
  def xid
    ptr = FFI::Pointer.new(glfw_window.to_i)
    xid=glfwGetX11Window(ptr)
  end
    
  # @option [:primary|nil] +monitor+
  def create monitor: @monitor
    x2,y2 = 600,600
    
    @glfw_window = glfwCreateWindow(x2,y2, "No See Me", monitor, nil )
    glfwMakeContextCurrent(glfw_window)
 
    GLib::Timeout.add(511) do
      (@_gdkwin||=Gdk::X11Window.new(Gdk::X11Display.default, xid)).reparent(Gdk::X11Window.new(Gdk::X11Display.default, ENV['XSCREENSAVER_WINDOW'].to_i(16)),0,0) if !ScreenSaver.demo
      false
    end
  end  
end

ScreenSaver.run( GtkGLFW::WindowCanvas.new(monitor: ScreenSaver.fullscreen ? nil : nil) do |gflw_window|
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
  glRotatef(glfwGetTime() * 50.0, 0.0, 0.0, 1.0)

  glBegin(GL_TRIANGLES)
  glColor3f(1.0, 0.0, 0.0)
  glVertex3f(-0.6, -0.4, 0.0)
  glColor3f(0.0, 1.0, 0.0)
  glVertex3f(0.6, -0.4, 0.0)
  glColor3f(0.0, 0.0, 1.0)
  glVertex3f(0.0, 0.6, 0.0)
  glEnd()
end )
