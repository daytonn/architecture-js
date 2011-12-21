module ArchitectureJS
  class Notification
    @@growl_support = false
    @@indicators = {
      none: "",
      log: "\e[32m>>>\e[0m ",
      event: "\e[33m<<<\e[0m ",
      added: "\e[32m+++\e[0m ",
      error: "\e[0;31m!!!\e[0m "
    }
    
    def self.notify(message, style)
      @@indicators[style] + message
    end
    
    def self.notice(message)
      self.notify(message, :none)
    end
    
    def self.log(message)
      self.notify(message, :log)
    end
    
    def self.event(message)
      self.notify(message, :event)
    end
    
    def self.added(message)
      self.notify(message, :added)
    end
    
    def self.error(message)
      self.notify(message, :error)
    end
    
  end
end