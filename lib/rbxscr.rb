class ScreenSaver
  CONFIG_FILE = File.join(ENV['HOME'],'.rbxscr')
  SAVERS_PATH = File.join(ENV['HOME'],'.rbxscr-savers')
  
  `mkdir -p #{SAVERS_PATH}`
  
  
  require 'json'
  
  def self.dump_config
    File.open(CONFIG_FILE,'w') do |f|
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
  def self.cycle len=(ENV['RB_XSCREEN_INTERVAL']||config[:interval]).to_i
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
    attr_accessor :fullscreen, :demo
  end 
  
  def self.load path
    p load_file: path
    require 'rbxscr/screen'
    super
    p EOF: __FILE__
  end
  
  def self.default
    d=config[:savers][v=(ENV['RB_XSCREEN_SAVER'] || config[:default])]
    d || v
  end 
  
  def self.add f
    config[:savers][k=File.basename(f).split(".")[0].gsub("-",'_').to_sym] = f
    dump_config
    k
  end

  def self.remove f
    if config[:savers][k=File.basename(f).split(".")[0].gsub("-",'_').to_sym]
      config[:savers].delete(k)
    else
      config[:savers].delete(f.to_sym)
    end
    
    dump_config
    k
  end
end
