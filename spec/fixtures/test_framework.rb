module TestFramework
  class Project < ArchitectureJS::Project

    def initialize(config, root = nil)
      @config = {
        framework: 'test',
        src_dir: 'modules',
        build_dir: 'application',
        dependencies: [],
        autoload: []
      }
      @config.merge! config unless config.nil?

      super(@config, root)
      @directories = %w'application elements lib models modules plugins spec'
    end
  end
end

# this line adds the default framework to ArchitectureJS
ArchitectureJS::register_framework('test', TestFramework::Project)