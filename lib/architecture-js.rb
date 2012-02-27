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

  def get_config_file(path)
    (Dir.entries(path).select { |f| f.match /\.blueprint$/ })[0]
  end

  module_function :base_directory,
                  :lib_directory,
                  :register_blueprint,
                  :get_config_file
end

module ArchitectureJS
  VERSION = File.read("#{base_directory}/VERSION")
  BLUEPRINTS = Hash.new
end

require "sprockets/lib/sprockets"

%w(dependencies generator notification blueprint architect).each do |lib|
  require "architecture-js/#{lib}"
end