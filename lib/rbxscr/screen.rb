$: << File.join(File.dirname(__FILE__))

require 'rbxscr/window'

class ScreenSaver
  attr_reader :window
  def initialize 
    @window = ScreenSaverWindow.new
  end
  
  def run
    window.show_all
    Gtk.main
  end
  
  def self.run &b
    b.call(@ins=new, @ins.window)
    @ins.run
  end 
  
  class Preferences < Gtk::Window
    def initialize
      self.title = 'Ruby XScreenSaver |  Preferences'
      set_default_size 600,800
    end
  end
  
  def self.preferences
    Preferences.new.show_all
    Gtk.main
  end
end
