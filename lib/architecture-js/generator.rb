module ArchitectureJS
  class Generator

    attr_accessor :template_paths,
                  :templates,
                  :project

    def initialize(project)
      @project = project
      @template_paths = @project.template_directories
      @templates = Hash.new
      find_templates @template_paths
    end

    def find_templates(paths)
      paths.each do |path|
        Dir["#{path}/*"].each do |file|
          add_file_to_templates file
        end
      end
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
      ERB.new File.read(file)
    end

    def generate(template, filename, options)
      filename = "#{filename}#{@templates[template][:ext]}"
      generate_file(filename, render_template(template, options), path)
    end

    def generate_file(filename, template, path = nil)
      path ||= File.expand_path(Dir.getwd)
      File.open("#{path}/#{filename}", "w+") { |f| f.write template }
    end

    def render_template(template, options = nil)
      project = @project
      @templates[template][:erb].result(binding)
    end
  end
end