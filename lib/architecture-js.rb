require "#{File.dirname(__FILE__)}/architecture-js/helpers"

module ArchitectureJS
  BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
  ROOT_DIR = Dir.getwd
  VERSION = File.read("#{BASE_DIR}/VERSION")
  FRAMEWORKS = Hash.new

  def register_framework(name, constructor)
    FRAMEWORKS[name] = constructor
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

  module_function :register_framework,
                  :create_project_from_config
end

Dir.glob(File.dirname(__FILE__) + '/architecture-js/*') { |file| require file }