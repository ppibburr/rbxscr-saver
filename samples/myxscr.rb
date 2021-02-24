require 'webkit2-gtk'

class WebSaver
  attr_reader :sites, :wv, :ss, :window
  def initialize ss
    @ss = ss
    @window = ss.window
    
    window.add @wv=WebKit2Gtk::WebView.new
  
    ua = ENV['WEB_SAVER_UA']
    wv.settings.user_agent = ua if ua
  
    @sites=[]

    if File.exist?(f=File.join(ENV['HOME'],".websaver_sites.txt"))
      @sites=open(f).read.split("\n").map do |s| s.strip end.find_all do |s| s!='' end.shuffle
    end
 
    ENV['WEB_SAVER_URI'] = sites[0] if lp=ENV['WEB_SAVER_LOOP']
  
    if !lp
      load_uri ENV['WEB_SAVER_URI']
    else
      cycle
    end    
  end

  def cycle
    i = -1
  
    load_uri sites[i+=1]
  
    GLib::Timeout.add(len=(ENV['WEB_SAVER_INTERVAL']||60).to_i*1000) do
      load_uri sites[i+=1]

      i = -1 if i >= (sites.length-1)
      true
    end
  end

  def load_uri uri
    wv.load_uri(u=uri||(sites[0]||'http://debian.org'))
  
    p uri: u
  
    GLib::Timeout.add 2000 do
      wv.zoom_level = (ENV['WEB_SAVER_ZOOM']||'1.8').to_f
      false
    end
  end
end

ScreenSaver.run do |ss,window|
  WebSaver.new(ss)
end
