module ArchitectureJS
  class Watcher

    attr_accessor :project, :listener

    def initialize(project)
      @project = project
      @listener = Listen.to(@project.root)
      @listener.ignore(/#{@project.config[:build_dir]}|spec|test/)
               .filter(/\.jst?|\.blueprint$/)
               .change do |modified, added, removed|
                 update_files(modified, "modified") if modified.length > 0 
                 update_files(added, "added") if added.length > 0
                 update_files(removed, "deleted") if removed.length > 0
               end
    end

    def watch
      @listener.start(false)
      self
    end

    def stop
      @listener.stop
    end

    private

      def update_files(files, action)
        files.each do |f|
          f = File.basename f
          if action == "deleted"
            puts "#{@project.root}/#{f}"
            FileUtils.rm_rf("#{@project.root}/#{f}")
            puts "remove #{@project.root}/#{f}"
          end

          puts "\n" << ArchitectureJS::Notification.event("#{f} was #{action}")
        end

        @project.read_config
        @project.update
        print ArchitectureJS::Notification.prompt
      end

  end
end