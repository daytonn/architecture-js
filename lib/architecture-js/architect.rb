require 'optparse'

module Architect

  class << self

    def application
      @application ||= Architect::Application.new
    end

  end

  class Application

    attr_reader :args,
                :command,
                :options

    def initialize(path = nil)
      if path
        @root = File.expand_path(path)
      else
        @root = File.expand_path(Dir.getwd)
      end
    end

    def run
      parse_options
      self.send(@command) if @command and not @options[:help]
      help unless @command or @options[:help]
    end

    def create
      app_name = @args.first
      if @args[1]
        sub_dir = @args[1] unless @args[1].match /^-/
      end
      blueprint = @options[:blueprint]

      raise 'you must specify a project name: architect create [project_name]' if args[0].nil?

      @root = File.expand_path sub_dir if sub_dir
      config = { name: app_name, blueprint: blueprint }

      require "#{blueprint}-architecture" unless blueprint == 'default'

      project = ArchitectureJS::BLUEPRINTS[blueprint].new(config, @root)
      project.create
    end

    def generate
      puts 'To be implemented'

      #conf_path = "#{config[:project].root}/ninjs.conf"
      #raise "ninjs.conf was not located in #{conf_path}" unless File.exists? conf_path
      #generator = ArchitectureJS::Generator.new(config)
      #generator.generate
    end

    def compile
      project = ArchitectureJS::create_project_from_config(File.expand_path(Dir.getwd))
      project.config[:output] = 'compressed' if options[:c] || options[:compress]
      project.update
    end
    #compile

    def watch
      require "fssm"
      path ||= Dir.getwd
      path = File.expand_path(path)

      puts ArchitectureJS::Notification.log "architect is watching for changes. Press Ctrl-C to stop."
      project = ArchitectureJS::Blueprint::new_from_config(path)
      project.update
      watch_hash = Hash.new
      watch_files = Dir["#{path}/**/"]
      watch_files.shift # remove the project root
       remove the build_dir
      watch_files.reject! { |dir| dir.match(/#{path}\/#{project.config[:build_dir]}/) }

      watch_files.each do |dir|
        watch_hash[dir] = "**/*.js"
      end

      watch_hash[path] = "**/*.architecture"
      watch_hash["#{ArchitectureJS::base_directory}/repository"] = "**/*.js" # check changes to the repository as well

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
    end
    #watch
    private
      def parse_options
        @options = {}
        OptionParser.new do |opts|
          opts.banner = "Usage: example.rb [options]"

          options[:version] = false
          opts.on("-v", "--version", "Version info") do
            @options[:version] = true
          end

          options[:blueprint] = 'default'
          opts.on('-f', '--blueprint FRAMEWORK', 'with blueprint') do |blueprint|
            @options[:blueprint] = blueprint
          end

          @options[:compress] = false
          opts.on('-c', '--compress', 'with compression') do
            @options[:compress] = true
          end

          opts.on('-h', '--help', 'Display help') do
            @options[:help] = true
            help
          end
        end.parse!

        @command = ARGV[0].to_sym if ARGV[0]
        @args = Array.try_convert(ARGV)
        @args.shift # remove command
      end

      def help
        puts File.read("#{ArchitectureJS::base_directory}/bin/HELP")
      end

  end

end