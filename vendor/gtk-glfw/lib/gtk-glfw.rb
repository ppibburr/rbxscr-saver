$: << File.dirname(__FILE__)

require "gtk-glfw/widgets"

include GLFWX11Window
include OpenGL
include GLFW

OpenGL.load_lib()
GLFW.load_lib()
glfwInit()
