module ArchitectureJS
  class Generator

    attr_accessor :template_paths,
                  :templates,
                  :blueprint,
                  :project

    def initialize(blueprint)
      @project = blueprint
      @blueprint = @project.config
      @template_paths = @project.template_directories
      @templates = Hash.new
      load_templates
    end

    def find_templates(paths)
      [*paths].each do |path|
        Dir["#{path}/*"].each do |file|
          add_file_to_templates file
        end
      end
    end

    def load_templates
      find_templates @template_paths
    end

    def add_file_to_templates(file)
      ext = File.extname(file)
      template_name = File.basename(file, ext)
      @templates[template_name] = {
        erb: read_template(file),
        ext: ext
      }
    end

    def read_template(file)
      ERB.new(File.read(file), nil, '<>')
    end

    def generate(config)
      template = config[:template]
      raise "There is no template named #{template} in the #{@blueprint[:name]} project" if @templates[template].nil?

      options = config[:options]
      arguments = config[:arguments]
      filename = "#{config[:filename]}#{@templates[template][:ext]}"

      generate_file(filename, render_template(template, filename, arguments, options))
    end

    def generate_file(filename, template, path = nil)
      path ||= File.expand_path(Dir.getwd)
      File.open("#{path}/#{filename}", "w+") { |f| f.write template }
    end

    def render_template(template, filename, arguments, options)
      blueprint = @blueprint
      project = @project
      @templates[template][:erb].result(binding)
    end
  end
end