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
      parse_arguments

      if @command == :generate
        parse_generate_options
      else
        parse_options
      end

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

      project = ArchitectureJS::create_project_from_config(project_path)
      template = @args.first
      filename = @args[1]
      options = @template_options

      project.generator.generate(template, filename, options)
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
      # remove the build_dir
      watch_files.reject! { |dir| dir.match(/#{path}\/#{project.config[:build_dir]}/) }

      watch_files.each do |dir|
        watch_hash[dir] = "**/*.js"
      end

      watch_hash[path] = "**/*.blueprint"
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
        @command = ARGV[0].to_sym if ARGV[0]
      end

      def help
        puts File.read("#{ArchitectureJS::base_directory}/HELP")
      end

  end

end