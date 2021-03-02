#
# For more samples, visit https://github.com/vaiorabbit/ruby-opengl/tree/master/sample .
#
# Ref.: /glfw-3.0.1/examples/simple.c
#

$: << f=File.expand_path(File.join(File.dirname(__FILE__), "..","..","..","gtk-x11-embed","lib"))

require 'gtk-x11-embed'

require 'opengl'
require 'glfw'
require 'ffi'

include GLFW
include OpenGL

OpenGL.load_lib
GLFW.load_lib
glfwInit

module GLFWX11Window
  extend FFI::Library
  ffi_lib 'glfw'
  attach_function :glfwGetX11Window, [:pointer], :int
  
  def glfwWindowMakeGDK window
    xid = glfwGetX11Window(FFI::Pointer.new(window.to_i))
    Gdk::X11Window.new(Gdk::X11Display.default, xid)
  end
end

module GtkGLFW
  # Widget embedding a glfwWindow
  module Widget  
    include GtkX11Embed::Socket
    
    attr_reader :glfw_window
    def initialize *o,&b
      super *o

      signal_connect "size-allocate" do
        if plugged       
          plugged.resize allocation.width,allocation.height if plugged
        end
        
        true
      end
      
      add_tick_callback do            
        unless plugged && plugged.viewable? && plugged.ensure_native && plugged.visible?
          next true
        end
       
        unless glfw_ready?
          next true
        end
       
        glfwMakeContextCurrent(glfw_window)
        
        b.call glfw_window if b

        glfwSwapBuffers( glfw_window )
        glfwPollEvents()        
        
        next true
      end 

      create
        
      signal_connect "realize" do
        GLib::Idle.add do
          take_window glfwWindowMakeGDK(glfw_window)        
        
          plugged.show
          plugged.resize allocation.width,allocation.height
          
          @_glfw_ready = true
          
          false
        end if !plugged
        
        false
      end
    end
    
    # @return [Integer] xid of the embedded glfwWindow
    def xid
      ptr = FFI::Pointer.new(glfw_window.to_i)
      @xid||=glfwGetX11Window(ptr)
    end

    
    # @return [true|false] GLFWWindow On screen and drawable
    def glfw_ready?
      @_glfw_ready
    end

    private
    def create   
      p h: y2=allocation.height
      p w: x2=allocation.width

      glfwWindowHint  GLFW_VISIBLE, GL_FALSE  
            
      @glfw_window = glfwCreateWindow(x2,y2, "??See Me",nil, nil )
    end
  end
end
