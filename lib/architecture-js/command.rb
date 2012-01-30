module ArchitectureJS
  module Command
    def watch(path = nil)
      require "fssm"
      path ||= Dir.getwd
      path = File.expand_path(path)

      puts ArchitectureJS::Notification.log "ArchitectureJS are watching for changes. Press Ctrl-C to stop."
      project = ArchitectureJS::Project::new_from_config(path)
      project.update
      watch_hash = Hash.new
      watch_files = Dir["#{path}/**/"]
      watch_files.shift # remove the project root
      # remove the build_dir
      watch_files.reject! { |dir| dir.match(/#{path}\/#{project.config[:build_dir]}/) }

      watch_files.each do |dir|
        watch_hash[dir] = "**/*.js"
      end

      watch_hash[path] = "**/*.architecture"
      watch_hash["#{ArchitectureJS::BASE_DIR}/repository"] = "**/*.js" # check changes to the repository as well

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

            delete do |base, relative|
              puts ArchitectureJS::Notification.event "#{relative} deleted"
              project.update
            end
          end
        end
      end
    end # watch

    def create(config = nil)
      settings = {
        name: nil,
        root: File.expand_path(Dir.getwd)
      }

      settings.merge!(config) unless config.nil?

      raise 'you must specify a project name: architect create ProjectName' if settings[:name].nil?

      project = ArchitectureJS::Project.new({ name: settings[:name] }, settings[:root])# TODO add settings[:framework]
      project.create
    end

    def compile(options = nil)
      settings = {
        force_compress: false,
        path: File.expand_path(Dir.getwd)
      }

      settings.merge!(options) if options

      project = ArchitectureJS::create_project_from_config(settings[:path])
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
