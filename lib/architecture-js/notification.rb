module ArchitectureJS
  class Notification

    win_platform = !![
      /bccwin/i,
      /djgpp/i,
      /mingw/i,
      /mswin/i,
      /wince/i,
    ].find{ |r| RUBY_PLATFORM =~ r }
    
    @@indicators = {
      none: "",
      log: "\e[32m>>>\e[0m",
      event: "\e[33m<<<\e[0m",
      added: "\e[32m+++\e[0m",
      error: "\e[0;31m!!!\e[0m"
    }

    @@indicators.merge! {
      none: "",
      log: ">>>",
      event: "<<<",
      added: "+++",
      error: "!!!"
    } if win_platform

    def self.notify(type, message)
      raise "There is no #{type} indicator" unless @@indicators[type]
      "#{@@indicators[type]} #{message}"
    end
    
    def self.notice(message)
      self.notify :none, message 
    end
    
    def self.log(message)
      self.notify :log, message
    end
    
    def self.event(message)
      self.notify :event, message
    end
    
    def self.added(message)
      self.notify :added, message
    end
    
    def self.error(message)
      self.notify :error, message
    end
    
  end
end