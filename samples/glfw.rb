#
# For more samples, visit https://github.com/vaiorabbit/ruby-opengl/tree/master/sample .
#
# Ref.: /glfw-3.0.1/examples/simple.c
#
require 'opengl'
require 'glfw'
require 'ffi'
require 'gtk3'

module GLFWX11Window
  extend FFI::Library
  ffi_lib 'glfw'
  attach_function :glfwGetX11Window, [:pointer], :int
  
  def embed d,window
    ptr = FFI::Pointer.new(window.to_i)
    p `xdotool windowreparent #{glfwGetX11Window(ptr)}  #{d.window.xid} `
  end
end

include GLFWX11Window
include OpenGL
include GLFW

ScreenSaver.run do |ss,w|
  w.window || w.realize
  
  GLib::Timeout.add(220) do
    p y2=w.allocation.height
    p x2=w.allocation.width

    pid=fork do;
      OpenGL.load_lib()
      GLFW.load_lib()  
      glfwInit()

      m = (ScreenSaver.demo) ? glfwGetPrimaryMonitor() : nil

      window = glfwCreateWindow( x2,y2, "No See Me", m, nil )

      glfwMakeContextCurrent(window)
      sleep 0.11
      embed w,window
      
      until false
        width_ptr = ' ' * 8
        height_ptr = ' ' * 8
        glfwGetFramebufferSize(window, width_ptr, height_ptr)
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

        glfwSwapBuffers( window )
        glfwPollEvents()
      end;
        
      glfwTerminate()
    end
    
    w.signal_connect "key-press-event" do
      `kill -15 #{pid}`
    end
    
    false
  end
end

