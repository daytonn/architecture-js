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

      # Go up to 10 levels up to look for the project config file
      # This is not optimal but is probably the easiest way to allow
      # generating templates in project sub-folders given we need to
      # read the blueprint file to get the templates
      10.times do
        config_file = ArchitectureJS::get_config_file(project_path)

        unless config_file
          path_array = project_path.split(File::SEPARATOR)
          path_array.pop # push the last dir off the stack
          project_path = path_array.join(File::SEPARATOR)
        else
          break
        end
      end

      project = ArchitectureJS::Blueprint.new_from_config(project_path)

      config = {
        arguments: @args,
        template: @args.first,
        filename: @args[1],
        options: @template_options
      }

      project.generator.generate config
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

      puts ArchitectureJS::Notification.log "architect is watching for changes. Press Ctrl-C to stop."
      project = ArchitectureJS::Blueprint::new_from_config(path)
      project.update
      
      Listen.to(path, :filter => /\.jst?$/, :ignore => /#{project.config[:build_dir]}|spec|test/) do |modified, added, removed|
        if modified.length > 0

          modified.each do |f|
            file = File.basename(f)
            puts ArchitectureJS::Notification.event "change detected in #{file}"
            project.config.read if f.match(/blueprint$/)
          end

          project.update
        end

        if added.length > 0
          added.each do |f|
            file = File.basename(f)
            puts ArchitectureJS::Notification.event "#{file} created"
          end

          project.update
        end

        if removed.length > 0
          removed.each do |f|
            file = File.basename(f)
            puts ArchitectureJS::Notification.event "#{file} deleted"
          end
        end

      end

    end
    #watch

    private
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

      def parse_arguments
        @args = Array.try_convert(ARGV)
        @args.shift # remove command
      end

      def parse_command
        unless ARGV[0].nil? && ARGV[0] =~ /^-/
          @command = ARGV[0].to_sym 
        end
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