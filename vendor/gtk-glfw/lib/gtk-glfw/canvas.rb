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

module GLFWX11Window
  extend FFI::Library
  ffi_lib 'glfw'
  attach_function :glfwGetX11Window, [:pointer], :int
end

module GtkGLFW
  # Widget embedding a glfwWindow
  module Widget  
    include GtkX11Embed::Socket
  
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
      
      signal_connect "destroy-event" do
        glfwTerminate()
      end
      
      signal_connect "size-allocate" do
        if glfw_ready?        
          plugged.resize allocation.width,allocation.height if plugged
        end
        
        true
      end
      
      run &b
    end
    
    # @return [Integer] xid of the embedded glfwWindow
    def xid
      ptr = FFI::Pointer.new(glfw_window.to_i)
      @xid||=glfwGetX11Window(ptr)
    end
    
    # @option [:primary|nil] +monitor+
    def create monitor: @monitor
      p h: y2=allocation.height
      p w: x2=allocation.width
      p monitor: monitor
      
      # Smooth looking
      glfwWindowHint  GLFW_VISIBLE, GL_FALSE  
      
      @glfw_window = glfwCreateWindow(x2,y2, "??See Me", monitor, nil )

      glfwMakeContextCurrent(glfw_window)
      
      GLib::Idle.add do
        take xid   
        false
      end 
    end
    
    # Setup and run the loop calling &b
    def run &b
      signal_connect "realize" do   
        # allow time for X plug window
        GLib::Idle.add do
          plugged ? plugged.show : false
          !plugged
          @go = true
        end
          
        false
      end
    
      # setup glfw window and context
      # loop the block
      signal_connect "draw" do
        unless glfw_window
          create;    # in here to allow final Gtk::Widget size to be known 
          queue_draw
          
          next
        end
       
        b.call glfw_window if b

        glfwSwapBuffers( glfw_window )
        glfwPollEvents()        
        queue_draw
      end
    end
    
    # @return [true|false] GLFWWindow On screen and drawable
    def glfw_ready?
      @go
    end
  end
end
