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
      if @command == :generate
        parse_arguments
        parse_generate_options
      else
        parse_options
        parse_arguments
      end

      if @command
          self.send @command unless @command =~ /^-/
      else
        help
      end

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
      project_path = File.expand_path(Dir.getwd)
      project = ArchitectureJS::Blueprint.new_from_config(project_path)

      config = {
        arguments: @args,
        template: @args.first,
        filename: @args[1],
        options: @template_options
      }
      begin
        project.generator.generate config
      rescue Exception => e
        puts e.message
        puts "Be sure you ran the command correctly (architect generate <template> <filename> [options])"
        puts "Available templates:"
        project.generator.templates.each { |k,v| puts "  - #{k}" }
      end
    end

    def compile
      project = ArchitectureJS::Blueprint.new_from_config(File.expand_path(Dir.getwd))
      project.config[:output] = 'compressed' if options[:c] || options[:compress]
      project.update
    end
    #compile

    def watch
      path ||= Dir.getwd
      path = File.expand_path(path)

      project = ArchitectureJS::Blueprint::new_from_config(path)
      project.update
      watcher = project.watch
      puts ArchitectureJS::Notification.log "architect is watching for changes. Type 'quit' or 'exit' to stop."
      start_interactive_session watcher
    end
    #watch

    private
      def start_interactive_session(watcher)
        begin
          command = ''
          while not command =~ /exit|quit/
              print ArchitectureJS::Notification.prompt
              command = gets.chomp
              case command
                when /exit|quit/
                  watcher.stop
                when /src_files/
                  puts watcher.project.src_files.join("\n")
                when /templates/
                  watcher.project.generator.templates.each { |k,v| puts k }
                when /compile/
                  begin
                    watcher.project.update
                  rescue Exception => e
                    puts e.message
                    ArchitectureJS::Notification.prompt
                  end
                when /generate/
                  begin
                    args = command.split(/\s/)
                    parse_command args
                    parse_arguments args
                    parse_generate_options
                    self.send @command
                  rescue Exception => e
                    puts e.message
                    puts "Available templates:"
                    watcher.project.generator.templates.each { |k,v| puts "  - #{k}" }
                    ArchitectureJS::Notification.prompt
                  end
                when /help/
                  puts 'Interactive commands:'
                  puts '  compile - compile the application'
                  puts '  generate - generate a template'
                  puts '  templates - list available templates to generate'
                  puts '  src_files - list source files to be compiled into the build_dir'
                  puts '  help - show this menu'
              end
          end
        rescue SystemExit, Interrupt
          puts
          watcher.stop
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

      def parse_generate_options
        @options = {
          help: false
        }
        @template_options = {}

        @args.each_with_index do |arg, i|
          # double dash options contain variables
          if arg.match(/^--/)
            option_key = arg.gsub(/^--/, '')
            option_value = @args[i + 1]

            if (option_value && option_value.match(/^-/) || option_value.nil?)
              # no option value
              @template_options[option_key.to_sym] = false
            else
              # option has a value
              @template_options[option_key.to_sym] = option_value
            end
          # single dash options are flags
          elsif arg.match(/^-/)
            @template_options[arg.gsub(/^-/, '').to_sym] = true
          end
        end
        # each_with_index
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