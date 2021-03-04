require 'webkit2-gtk'

coins = {
  BTC: :USD,
  XLM: :USD,
  LTC: :USD,
  BAT: :USDC,
  ETC: :USD,
}.map do |k,v|
  "#{k}=#{v}"
end.join("&")


ScreenSaver.run do |ss,window|
  window.add wv=WebKit2Gtk::WebView.new
  wv.load_uri "http://0.0.0.0:4567/coins?#{coins}"

  GLib::Timeout.add 1700 do
    wv.reload
    true
  end

  GLib::Timeout.add 2000 do
    wv.zoom_level = 2.1
    false
  end
end
