require 'webkit2-gtk'

ScreenSaver.run do |ss,window|
  window.add wv=WebKit2Gtk::WebView.new
  wv.load_uri "https://trade.kraken.com/markets?exchanges=kraken&types=spot%2Bfutures"

  GLib::Timeout.add 2000 do
    wv.zoom_level = 2.1
    false
  end
end
