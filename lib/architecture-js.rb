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

  def register_blueprint(name, constructor)
    ArchitectureJS::BLUEPRINTS[name] = constructor
  end

  def create_project_from_config(project_dir = nil)
    project_dir ||= File.expand_path(Dir.getwd)
    conf_file = (Dir.entries(project_dir).select { |f| f.match /\.architecture$/ })[0]
    raise "<project_name>.architecture was not found in #{project_dir}" if conf_file.nil?

    config = YAML.load_file("#{project_dir}/#{conf_file}")
    config = ArchitectureJS::Helpers::symbolize_keys config

    raise "The config file does not contain a project name" if config[:name].nil?
    raise "#{config[:blueprint]} is not isntalled. Try gem install #{config[:blueprint]}-architecture" if ArchitectureJS::BLUEPRINTS[config[:blueprint]].nil?

    project = ArchitectureJS::BLUEPRINTS[config[:blueprint]].new(config, project_dir)
  end

  module_function :base_directory,
                  :lib_directory,
                  :register_blueprint,
                  :create_project_from_config
end

module ArchitectureJS
  VERSION = File.read("#{base_directory}/VERSION")
  BLUEPRINTS = Hash.new
end

require "sprockets/lib/sprockets"

%w(dependencies generator notification blueprint architect).each do |lib|
  require "architecture-js/#{lib}"
end