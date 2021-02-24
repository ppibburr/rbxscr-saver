class ScreenSaver
  CONFIG_FILE = File.join(ENV['HOME'],'.rbxscr')
  SAVERS_PATH = File.join(ENV['HOME'],'.rbxscr-savers')
  
  `mkdir -p #{SAVERS_PATH}`
  
  
  require 'json'
  
  def self.dump_config
    File.open(CONFIG_FILE,'w') do |f|
      p config
      f.puts JSON.pretty_generate(config)
    end
  end
  
  def self.config
    @config ||= JSON.parse(open(CONFIG_FILE).read, symbolize_names: true)
  rescue => e
    @config = {savers: {}}
  end
  
  config
  dump_config
  
  PID = Process.pid
  def self.cycle len=4
    at_exit {
      `kill -15 #{@pid}` if @pid
    }
    
    i    = -1
    @pid = nil
  
    loop do
      `kill -15 #{@pid}` if @pid
      savers.map do |n,f|
        `kill -15 #{@pid}` if @pid
        
        @pid = fork do
          load f
        end
      
        p loaded: n
      
        sleep len
      end
    end
  end
  
  def self.savers
    if !@savers
      @savers = h = Dir.glob(File.join(SAVERS_PATH,"/*.rb")).map do |f| [File.basename(f).split(".")[0].gsub("-",'_'), f] end.to_h
      (config[:savers] ||= {}).map do |k,v| h[k] = v end
    end
    
    @savers
  end
  
  def self.alive? pid
    Process.kill(0, pid )
    true
  rescue
    false
  end
  
  class << self
    attr_accessor :fullscreen
  end 
  
  def self.load path
    p load_file: path
    require 'rbxscr/screen'
    super
    p EOF: __FILE__
  end
  
  def self.default
    ENV['RB_XSCREEN_SAVER'] || config[:default]
  end 
end
