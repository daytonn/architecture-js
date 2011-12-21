module ArchitectureJS
  BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIB_DIR = File.expand_path(File.join(File.dirname(__FILE__)))
  ROOT_DIR = Dir.getwd
  VERSION = File.read("#{BASE_DIR}/VERSION")
  FRAMEWORKS = Hash.new

  def register_framework(name, constructor)
    FRAMEWORKS[name] = constructor
  end

  module_function :register_framework
end

Dir.glob(File.dirname(__FILE__) + '/architecture-js/*') { |file| require file }