module Architect

  class << self

    def application
      @application ||= Architect::Application.new
    end

  end

  class Application

    attr_reader :args,
                :command,
                :commands,
                :options,
                :subcommands

    def initialize
      @command = ARGV[0].to_sym if ARGV[0]
      @args = Array.try_convert(ARGV)
      @args.shift
      @options = {}
      @subcommands = {}
      @commands = [:create, :generate, :compile, :watch]
      @help = create_help
      @aliases = {
        :framework => :f
      }
    end

    def run
      parse_args unless @args.empty?
      if @command
        if options[:h]
          help @command
        else
          if @commands.include? @command
            self.send @command
          else
            puts ArchitectureJS::Notification.error "#{@command} is not a valid command"
          end
        end
      else
        help
      end
    end

    def create
      app_name = @args[0]
      # default root to nil or sub directory
      root = @args[1] || nil unless @args[1] =~ /^\-/
      framework = @options[:f] ? @args[@options[:f] + 1] : 'none'

      if app_name.nil?
        puts "Error! Application name is required (architect create app_name)"
        exit
      end

      config = { name: app_name, framework: framework }

      ArchitectureJS::Command.create(config, root)
    end

    def generate
      puts 'To be implemented'
    end

    def compile
      if options[:c] || options[:compress]
        ArchitectureJS::Command.compile({ force_compress: true })
      else
        ArchitectureJS::Command.compile
      end
    end

    def watch
      ArchitectureJS::Command.watch
    end

    private
      def parse_args
        @args.each_index do |i|
          if @args[i] =~ /^\-/
            parse_flag i
          elsif args[i] =~ /\:/
            parse_key_value_pair @args[i]
          else
            add_subcommand @args[i], i
          end
        end
      end

      def parse_flag(i)
        key = @args[i].gsub(/^\-+/, '')

        if short_key = @aliases[key.to_sym]
          @options[short_key.to_s] = i
          @options[short_key] = i
        end

        @options[key] = i
        @options[key.to_sym] = i
      end

      def parse_key_value_pair(arg)
        m = arg.match(/([\w|\-|]+)\:(\"|\')?(.*)(\"|\')?/)
        key = m.captures[0]
        value = m.captures[2]
        @options[key] = value
        @options[key.to_sym] = value
      end

      def add_subcommand(arg, index)
        #@subcommands[arg] = [sub args]
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