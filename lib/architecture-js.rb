module ArchitectureJS
end

require "architecture-js/helpers"

module ArchitectureJS
  def base_directory
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  def lib_directory
    File.expand_path(File.join(File.dirname(__FILE__)))
  end

  def root_directory
    File.expand_path(File.join(File.dirname(Dir.getwd)))
  end

  def register_framework(name, constructor)
    ArchitectureJS::FRAMEWORKS[name] = constructor
  end

  def create_project_from_config(project_dir = nil)
    project_dir ||= File.expand_path(Dir.getwd)
    conf_file = (Dir.entries(project_dir).select { |f| f.match /\.architecture$/ })[0]
    raise "<project_name>.architecture was not found in #{project_dir}" if conf_file.nil?

    config = YAML.load_file("#{project_dir}/#{conf_file}")
    config = ArchitectureJS::Helpers::symbolize_keys config

    raise "The config file does not contain a project name" if config[:name].nil?
    raise "#{config[:framework]} is not isntalled. Try gem install #{config[:framework]}-architecture" if ArchitectureJS::FRAMEWORKS[config[:framework]].nil?

    project = ArchitectureJS::FRAMEWORKS[config[:framework]].new(config, project_dir)
  end

  module_function :base_directory,
                  :lib_directory,
                  :register_framework,
                  :create_project_from_config
end

module ArchitectureJS
  VERSION = File.read("#{base_directory}/VERSION")
  FRAMEWORKS = Hash.new
end

require "sprockets/lib/sprockets"

%w(dependencies generator notification project architect).each do |lib|
  require "architecture-js/#{lib}"
end