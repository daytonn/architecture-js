module ArchitectureJS
  class Project
    attr_accessor :root,
                  :src_files,
                  :framework,
                  :config_name,
                  :directories,
                  :template_directories,
                  :generator,
                  :config

    # this line adds the default framework to ArchitectureJS
    ArchitectureJS::register_framework 'none', self

    def self.new_from_config(path)
      config_file = Dir.entries(path).select {|f| f =~ /\.architecture$/ }.first

      raise ".architecture file was not found in #{path}" if config_file.nil?

      config = YAML::load_file "#{path}/#{config_file}"
      config = ArchitectureJS::Helpers::symbolize_keys config

      raise "#{config[:framework]} is unavailable or not installed" if ArchitectureJS::FRAMEWORKS[config[:framework]].nil?

      project = ArchitectureJS::FRAMEWORKS[config[:framework]].new config, path
    end

    def initialize(config, root = nil)
      raise "#{self.class}.new({ name: 'myapp' }, options): config[:name] is undefined" unless config[:name]
      @config_file = "#{config[:name].downcase}.architecture"
      root ||= Dir.getwd
      @root = File.expand_path(root)
      @template_directories = ["#{ArchitectureJS::BASE_DIR}/templates", "#{@root}/templates"]
      @directories = ['lib', 'src']
      @src_files = Array.new
      @config = {
        framework: 'none',
        src_dir: 'src',
        build_dir: 'lib',
        asset_root: '../',
        output: 'compressed'
      }
      @config.merge! config unless config.nil?
      @generator = ArchitectureJS::Generator.new self
    end
  
    def read_config
      config = YAML::load_file("#{@root}/#{@config_file}")
      assign_config_variables config
    end

    def assign_config_variables(config)
      config.each do |key, value|
        @config[key.to_sym] = value
      end
    end

    def create
      puts ArchitectureJS::Notification.notice "Creating the #{@config[:name]} project in #{@root}" 
      create_project_scaffold
      write_config
      create_application_file
    end

    def create_project_scaffold
      Dir.mkdir "#{@root}" unless File.exists? "#{@root}"

      @directories.each do |dir|
        puts ArchitectureJS::Notification.added "#{dir} created" unless File.exists? "#{@root}/#{dir}"
        Dir.mkdir "#{@root}/#{dir}" unless File.exists? "#{@root}/#{dir}"
      end
    end

    def write_config
      File.open("#{@root}/#{@config_file}", "w+") do |conf_file|
        @config.each do |key, value|
          conf_file << "#{key}: #{ArchitectureJS::Helpers.array_to_yml value}\n" if value.is_a? Array
          conf_file << "#{key}: #{value}\n" if value.is_a? String
        end
      end

      puts ArchitectureJS::Notification.added "#{@config_file} created"
    end

    def create_application_file
      FileUtils.touch("#{@root}/#{@config[:src_dir]}/#{@config[:name]}.js")
    end

    def update
      get_src_files
      compile_src_files
      compress_application if @config[:output] == 'compressed'
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
      app_root = File.expand_path "#{@root}/#{@config[:build_dir]}"
      src_files = Dir.entries(app_root).reject! { |file| file =~ /^\./ }

      src_files.each do |file|
        full_path = "#{app_root}/#{file}"
        uncompressed = File.open(full_path, "r").read
        File.open(full_path, "w+") do |file|
          file << JSMin.minify(uncompressed).gsub(/\n?/, '')
        end
      end
    end

  end # class Project
end # module ArchitectureJS