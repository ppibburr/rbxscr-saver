require 'gtk-glfw'

ScreenSaver.run( GtkGLFW::Window.new do |gflw_window|
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
  glRotatef(glfwGetTime() * 125.0, 0.0, 0.0, 1.0)

  glBegin(GL_TRIANGLES)
  glColor3f(1.0, 0.0, 0.0)
  glVertex3f(-0.6, -0.4, 0.0)
  glColor3f(0.0, 1.0, 0.0)
  glVertex3f(0.6, -0.4, 0.0)
  glColor3f(0.0, 0.0, 1.0)
  glVertex3f(0.0, 0.6, 0.0)
  glEnd()
end )
