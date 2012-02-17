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
      self.send(@command)
    end

    def create
      app_name = @args.first
      if @args[1]
        sub_dir = @args[1] unless @args[1].match /^-/
      end
      framework = @options[:framework]

      raise 'you must specify a project name: architect create [project_name]' if args[0].nil?

      @root = File.expand_path sub_dir if sub_dir
      config = { name: app_name, framework: framework }

      require "#{framework}-architecture" unless framework == 'none'

      project = ArchitectureJS::FRAMEWORKS[framework].new(config, @root)
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

    def watch
      require "fssm"
      path ||= Dir.getwd
      path = File.expand_path(path)

      puts ArchitectureJS::Notification.log "architect is watching for changes. Press Ctrl-C to stop."
      project = ArchitectureJS::Project::new_from_config(path)
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

    private
      def parse_options
        @options = {}
        OptionParser.new do |opts|
          opts.banner = "Usage: example.rb [options]"

          options[:version] = false
          opts.on("-v", "--version", "Version info") do
            @options[:version] = true
          end

          options[:framework] = 'none'
          opts.on('-f', '--framework FRAMEWORK', 'with framework') do |framework|
            @options[:framework] = framework
          end

          @options[:compress] = false
          opts.on('-c', '--compress', 'with compression') do
            @options[:compress] = true
          end

          opts.on('-h', '--help', 'Display help') do
            puts 'Show help'
          end
        end.parse!

        @command = ARGV[0].to_sym
        @args = Array.try_convert(ARGV)
        @args.shift # remove command
      end

      def help(command = nil)
        help = command || [*@commands, :footer]
        [*help].each do |command|
          puts @help[command]
        end
      end

      def create_help
        help = {}
        help[:create] = <<-CREATE
            create    Creates a new architecture-js application in the current working 
                      directory or sub directory within.

                      Arguments:
                      application name - Name of the architecture-js application
                      subdirectory* - Directory where the application will be 
                                      installed (created if nonexistent)

                      examples:
                      architect create myapp
                      architect create myapp subdirectory
        CREATE
      
        help[:generate] = <<-GEN
            generate  Generates scoffolding from a template. 

                      Arguments:
                      name - Name of the template to generate

                      Options:
                      *Options are arbitrary (optional) arguments specific to templates
                      There are two types of options: boolean and named attributes

                      examples:
                      architect generate mytemplate -f (boolean arguments use a single "-")
                      architect generate mytemplate foo:"Hello" (named arguments can be boolean by passing no value)
                      architect genreate mymodule -f foo:"Hello" (combined to generate complex templates)
        GEN

        help[:compile] = <<-COMP
          compile   Compiles the architecture-js project in the current working directory.

                    Options:
                    -c, --compress - Compress output with JsMin

                    example:
                    architect compile
        COMP

        help[:watch] = <<-WATCH
          watch     Watches the current working directory for file changes and
                    compiles when changes are detected.
          
                    example:
                    architect watch
        WATCH

        help[:footer] = <<-FOOTER

        * optional argument
        
        FOOTER

        help
      end
  end

end