module TestFramework
  class Project < ArchitectureJS::Blueprint

    def initialize(config, root = nil)
      @config = {
        blueprint: 'test',
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

# this line adds the default blueprint to ArchitectureJS
ArchitectureJS::register_blueprint('test', TestFramework::Project)