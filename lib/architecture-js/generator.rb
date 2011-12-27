module ArchitectureJS
  class Generator

    attr_reader :template_paths,
                :templates,
                :project

    def initialize(project)
      @project = project
      @template_paths = @project.template_directories
      @templates = Hash.new
      find_templates @template_paths
      #@template_dir = template_dir
      #@template_files = Dir.entries(template_dir).reject {|file| file.match /^\./ }
      #@templates = Hash.new
      #@template_files.each do |file|
      #  name = file.gsub /\.\w+$/, ''
      #  @templates[name] = ERB.new(File.read(File.expand_path(file, @template_dir)))
      #end
    end

    def find_templates(paths)
      paths.each do |path|
        Dir["#{path}/*_template*"].each do |file|
          template_name = get_template_name file
          @templates[template_name] = get_template(file)
        end
      end
    end

    def get_template_name(file)
      file.split(/\/|\\/).last.gsub(/_template\.\w*/, '')
    end

    def get_template(file)
      ERB.new File.read(file)
    end

    def render_template(template, options = nil)
      project = @project
      @templates[template].result(binding)
    end
  end
end