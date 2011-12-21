module ArchitectureJS
  class Project # TODO make generator belong to project to have default templates hooked up to generator
    attr_reader :root,
                :config,
                :src_files,
                :framework

    attr_accessor :config_name

    # this line adds 
    ArchitectureJS::register_framework
    
    def self.init_with_config(options = nil)
      # TODO the project needs to be able to access the custom framework class
      self.new(options).read_config
    end

    def initialize(name, options = nil)
      @settings = {
        root: Dir.getwd,
        config_file: "#{name.downcase}.architecture"
      }
      @settings.merge!(options) unless options.nil?
      @root = File.expand_path(@settings[:root])
      @directories = ['lib', 'src']
      @src_files = Array.new
      @config = {
        name: name,
        src_dir: 'src',
        build_dir: 'lib',
        asset_root: '../',
        output: 'compressed'
      }
    end

    def read_config
      config = YAML.load_file("#{@root}/#{@config[:name]}.conf")
      config.each do |key, value|
        @config[key.to_sym] = value
      end
      self
    end

    def create
      puts ArchitectureJS::Notification.notice "Creating the #{@name} project in #{@root}" 
      create_project_scaffold
      write_config
    end

    def create_project_scaffold
      Dir.mkdir "#{@root}" unless File.exists? "#{@root}"

      @directories.each do |dir|
        puts ArchitectureJS::Notification.added "#{dir} created" unless File.exists? "#{@root}/#{dir}"
        Dir.mkdir "#{@root}/#{dir}" unless File.exists? "#{@root}/#{dir}"
      end
    end

    def write_config
      File.open("#{@root}/#{@settings[:config_file]}", "w+") do |conf_file|
        @config.each do |key, value|
          Array conf_file << "#{key}: #{ArchitectureJS::Helpers.array_to_yml value}\n" if value.is_a?
          String conf_file << "#{key}: #{value}\n" if value.is_a?
        end
      end

      puts ArchitectureJS::Notification.notify "#{@name}.conf created", :added
    end

    def update
      get_src_files
      compile_src_files
      compress_application if @output == 'compressed'
      puts ArchitectureJS::Notification.log "application updated" unless @errors
      @errors = false
    end

    def get_src_files
      [*@config[:src_dir]].each do |directory| 
        add_src_files_to_project File.expand_path(directory, @root)
      end
    end

    def add_src_files_to_project(directory)
      Dir["#{directory}/*.js"].each do |file|
        src_filename = file.gsub(directory, '')
        @src_files << "#{directory}#{src_filename}" unless src_filename.match(/^\/_/)
      end
    end

    def compile_src_files
      @src_files.each do |file_path|
        file_name = ArchitectureJS::Helpers.get_file_name file_path
        compile_src_file file_path, file_name
      end
    end

    def compile_src_file(file_path, file_name)
      sprockets = Sprockets::Secretary.new(
        :root         => "#{ArchitectureJS::BASE_DIR}",
        :asset_root   => File.expand_path(@config[:asset_root], @root),
        :load_path    => ["repository"],
        source_files: ["#{file_path}"]
      )

      compiled_file = sprockets.concatenation
      message = File.exists?("#{@root}/#{@config[:build_dir]}/#{file_name}.js") ? "\e[32m>>>\e[0m #{@config[:build_dir]}/#{file_name}.js updated" : "\e[32m>>>\e[0m #{@config[:build_dir]}/#{file_name}.js created"
      compiled_file.save_to "#{@root}/#{@config[:build_dir]}/#{file_name}.js"
      sprockets.install_assets

    rescue Exception => error
      @errors = true
      puts ArchitectureJS::Notification.error "Sprockets error: #{error.message}"
    end

    def compress_application
      app_root = File.expand_path "#{@config[:build_dir]}"
      src_files = Dir.entries(app_root)
      src_files.reject! { |file| file =~ /^\./ }

      src_files.each do |module_file|
        full_path = "#{app_root}/#{module_file}"
        uncompressed = File.open(full_path, "r").read
        File.open(full_path, "w+") do |module_file|
          module_file << JSMin.minify(uncompressed)
        end
      end
    end

  end # class Project
end # module ArchitectureJS