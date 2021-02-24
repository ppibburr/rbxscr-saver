ScreenSaver.run do |ss,window|
  window.add l=Gtk::Label.new
  l.text = __FILE__
end
