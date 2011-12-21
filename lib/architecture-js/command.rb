module ArchitectureJS
  module Command
    def watch(path = nil)
      require "fssm"
      
      path ||= File.expand_path(Dir.getwd)

      puts ArchitectureJS::Notification.log "ArchitectureJS are watching for changes. Press Ctrl-C to stop."
      project = ArchitectureJS::Project.init_with_config
      project.update
	    
	    watch_dirs = ArchitectureJS::Manifest.directories.reject { |dir| dir.match(/application|tests/) }
	    watch_hash = Hash.new
	    
	    watch_dirs.each do |dir|
	     watch_hash["#{path}/#{dir}"] = "**/*.js"
	    end
	    
	    watch_hash[path] = "**/*.conf"
	    watch_hash["#{ArchitectureJS::BASE_DIR}/repository"] = "**/*.js"
	    
	    FSSM.monitor do

	      watch_hash.each do |dir, g|
	        
  	     path "#{dir}" do
           glob g

           update do |base, relative|
             puts ArchitectureJS::Notification.event "change detected in #{relative}"
             project.config.read if relative.match(/conf$/)
             project.update
           end

           create do |base, relative|
             puts ArchitectureJS::Notification.event "#{relative} created"
             project.update
           end
         end
         
  	    end

	    end
	           
    end

    def create(config = nil)
      settings = {
        name: nil,
        root: File.expand_path(Dir.getwd)
      }
      
      settings.merge!(config) unless config.nil?
      
      raise 'you must specify a project name: arcjs create ProjectName' if settings[:name].nil?

      project = ArchitectureJS::Project.new({ name: settings[:name], root: settings[:root] })# TODO add settings[:framework]
      project.create
    end
    
    def compile(options = nil)
      settings = {
        force_compress: false,
        path: File.expand_path(Dir.getwd)
      }
      
      settings.merge!(options) unless options.nil?
      
      project = ArchitectureJS::Project.init_with_config(root: settings[:path])
      project.config[:output] = 'compressed' if settings[:force_compress]
      project.update
    end
    
    # TODO make generate generic to accept a type, look up in either local templates or master, and pass it options and flags parsed for use in erb files
    def generate(config)
      conf_path = "#{config[:project].root}/ninjs.conf"
      raise "ninjs.conf was not located in #{conf_path}" unless File.exists? conf_path
      generator = ArchitectureJS::Generator.new(config)
      generator.generate
    end
    
    module_function :create,
                    :watch,
                    :compile,
                    :generate
  end
end
