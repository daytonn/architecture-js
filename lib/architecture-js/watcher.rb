module ArchitectureJS
  class Watcher

    attr_accessor :project, :listener

    def initialize(project)
      @project = project
      @listener = Listen.to(@project.root)
      @listener.ignore(/#{@project.config[:build_dir]}|spec|test/)
               .filter(/\.jst?$/)
               .change do |modified, added, removed|
                 update_files(modified, "was modified") if modified.length > 0 
                 update_files(added, "was added") if added.length > 0
                 update_files(removed, "was deleted") if removed.length > 0
               end
    end

    def watch
      @listener.start(false)
      self
    end

    private

      def update_files(files, message)
        files.each do |f|
          f = File.basename f

          puts "\n" << ArchitectureJS::Notification.event("#{f} #{message}")
        end

        @project.read_config
        @project.update
        print ArchitectureJS::Notification.prompt
      end

  end
end