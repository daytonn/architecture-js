module ArchitectureJS
  class Generator

    attr_reader :template_dir,
                :project,
                :template_files,
                :templates

    def initialize(template_dir)
      @template_dir = template_dir
      @template_files = Dir.entries(template_dir).reject {|file| file.match /^\./ }
      @templates = Hash.new
      @template_files.each do |file|
        name = file.gsub /\.\w+$/, ''
        @templates[name] = ERB.new(File.read(File.expand_path(file, @template_dir)))
      end
    end

    def render_template(template, project, options = nil)
      @templates[template].result(binding)
    end
  end
end