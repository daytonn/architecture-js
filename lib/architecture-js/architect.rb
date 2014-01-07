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
      parse_command
      parse_options
      parse_arguments

      if @command
          self.send @command unless @command =~ /^-/
      else
        help
      end

    end

    def create
      app_name = @args.first
      if @args[1]
        sub_dir = @args[1] unless @args[1].match(/^-/)
      end
      blueprint = @options[:blueprint]

      raise 'You must specify a project name: architect create [project_name]' if args[0].nil?

      @root = File.expand_path sub_dir if sub_dir
      config = { name: app_name, blueprint: blueprint }

      require "#{blueprint}-architecture" unless blueprint == 'default'

      @project = ArchitectureJS::BLUEPRINTS[blueprint].new(config, @root)
      @project.create
    rescue Exception => e
      puts ArchitectureJS::Notification.error e.message
    end

    def compile
      @project = ArchitectureJS::Blueprint.init_with_config(@root)
      compress = @options[:c] || @options[:compress]
      @project.update(compress)
    rescue Exception => e
      puts ArchitectureJS::Notification.error e.message
    end

    def watch
      @project = ArchitectureJS::Blueprint.init_with_config(@root)
      @project.update
      @watcher = @project.watch("architect is watching for changes. Type 'quit' or 'exit' to stop.")
      start_interactive_session
    rescue Exception => e
      puts ArchitectureJS::Notification.error e.message
    end

    def src_files
      @project = ArchitectureJS::Blueprint.init_with_config(@root)
      puts "Source files:"
      @project.src_files.each { |f| puts "  - #{File.basename f}" }
    rescue Exception => e
      puts ArchitectureJS::Notification.error e.message
    end

    private
      def start_interactive_session
        @command = ''

        while not @command =~ /^(quit|exit)$/
          print ArchitectureJS::Notification.prompt
          @command = gets.chomp
          args = @command.split(/\s/)
          parse_command args

          case @command
          when /^(quit|exit)$/
            @watcher.stop
          when /help/
            puts 'Interactive commands:'
            puts '  compile - compile the application'
            puts '  src_files - list source files to be compiled into the build_dir'
            puts '  help - show this menu'
            puts '  quit - stop watching for changes'
          when /compile|src_files/
            args = args.drop 1
            parse_interactive_options args
            parse_arguments args

            self.send @command
          else
              puts ArchitectureJS::Notification.error "Unrecognized command `#{command}`. Try `help` or `quit`."
          end
        end
      rescue SystemExit, Interrupt
        puts
        @watcher.stop
      end

      def parse_interactive_options(args = [])
        @options = {}

        args.each do |option|
          case option
          when /\-c|\-\-compress/
            @options[:compress] = true
            @options[:c] = true
          end
        end
      end

      def parse_options
        @options = {}
        OptionParser.new do |opts|
          opts.on("-v", "--version", "Version info") do
            @options[:version] = true
            version
          end

          @options[:blueprint] = 'default'
          opts.on('-b', '--blueprint FRAMEWORK', 'with blueprint') do |blueprint|
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
      end

      def parse_arguments(args = Array.try_convert(ARGV))
        @args = args
        @args.shift # remove command
      end

      def parse_command(args = ARGV)
        @command = args[0].to_sym if args[0].respond_to? :to_sym
      end

      def help
        puts File.read("#{ArchitectureJS::base_directory}/HELP")
      end

      def version
        version = File.read("#{ArchitectureJS::base_directory}/VERSION")
        authors = File.readlines("#{ArchitectureJS::base_directory}/AUTHORS").join(', ')
        message = "ArchitectureJS #{version}\n"
        message << "Copyright (c) 2011 #{authors}\n"
        message << "Released under the MIT License."
        puts message
      end
  end

end
