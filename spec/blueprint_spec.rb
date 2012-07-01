require "spec_helper.rb"

describe ArchitectureJS::Blueprint do

  it "should exist" do
    ArchitectureJS::Blueprint.should_not be_nil
  end

  context 'Instantiation' do
    before :each do
      FileUtils.mkdir TMP_DIR
      suppress_output do
        @project = ArchitectureJS::Blueprint.new({ name: 'myapp' }, TMP_DIR)
      end
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
    end

    it "should add the 'default' blueprint to ArchitectureJS" do
      ArchitectureJS::BLUEPRINTS['default'].should == ArchitectureJS::Blueprint
    end

    it 'should have an empty src_files array' do
      @project.src_files.should == Array.new
    end

    it 'should have a read_config method' do
      @project.respond_to?("read_config").should be_true
    end

    it 'should have a write_config method' do
      @project.respond_to?("write_config").should be_true
    end

    it "should have directories" do
      @project.directories.should == ['lib', 'src']
    end

    it "should have template_directories" do
      @project.template_directories.should == ["#{TMP_DIR}/templates"]
    end

    context "with existing project" do
      before(:each) do
        FileUtils.cp("#{FIXTURES}/myapp.blueprint", "#{TMP_DIR}/myapp.blueprint")
      end

      it "should initialize with a config path" do
        @existing = ArchitectureJS::Blueprint.init_with_config TMP_DIR
        @existing.config.should_not be_empty
        @existing.config[:name].should == 'myapp'
      end

    end
  end # Instantiation

  context "- Creation -" do
   before :each do
     FileUtils.mkdir("#{TMP_DIR}")
     suppress_output do
       @project = ArchitectureJS::Blueprint.new({ name: 'myapp' }, TMP_DIR)
       @project.create
     end
   end

   after :each do
     FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
   end

   it 'should create a project directory structure' do
     File.directory?("#{TMP_DIR}/lib").should be_true
     File.directory?("#{TMP_DIR}/src").should be_true
   end

   it 'should create a config file' do
     File.exists?("#{TMP_DIR}/myapp.blueprint").should be_true
     "#{TMP_DIR}/myapp.blueprint".should be_same_file_as "#{FIXTURES}/myapp.blueprint"
   end

   it "should create an application source file" do     
     File.exists?("#{TMP_DIR}/src/myapp.js").should be_true
   end
  end # Project Creation

  context "- Update -" do
    before :each do
      FileUtils.mkdir("#{TMP_DIR}")
      suppress_output do
        @project = ArchitectureJS::Blueprint.new({ name: 'myapp' },TMP_DIR)
        @project.create
        FileUtils.cp "#{FIXTURES}/lib1.js", "#{TMP_DIR}/src/lib1.js"
        FileUtils.cp "#{FIXTURES}/lib2.js", "#{TMP_DIR}/src/lib2.js"
        FileUtils.cp "#{FIXTURES}/src_file.js", "#{TMP_DIR}/src/myapp.js"
        FileUtils.cp "#{FIXTURES}/_hidden.js", "#{TMP_DIR}/src/"
        @project.update
      end
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
    end

    it 'should compile the source files into the destination folder' do
      File.exists?("#{TMP_DIR}/lib/myapp.js").should be_true
      "#{TMP_DIR}/lib/myapp.js".should be_same_file_as "#{FIXTURES}/compressed.js"

      File.exists?("#{TMP_DIR}/lib/lib1.js").should be_true
      "#{TMP_DIR}/lib/lib1.js".should be_same_file_as "#{FIXTURES}/lib1_compressed.js"

      File.exists?("#{TMP_DIR}/lib/lib2.js").should be_true
      "#{TMP_DIR}/lib/lib2.js".should be_same_file_as "#{FIXTURES}/lib2_compressed.js"
    end

    it 'should compress the application file' do
      FileUtils.cp "#{FIXTURES}/compressed.blueprint", "#{TMP_DIR}/myapp.blueprint"
      @project.config[:output].should == 'compressed'
    end

    it 'should not compile src files begining with _' do
      File.exists?("#{TMP_DIR}/lib/_hidden.js").should_not be_true
    end

  end # Project Update

  context "- Config Update -" do
    before :each do
      FileUtils.mkdir("#{TMP_DIR}")
      suppress_output do
        @project = ArchitectureJS::Blueprint.new({ name: 'myapp' },TMP_DIR)
        @project.create
        FileUtils.cp "#{FIXTURES}/update.blueprint", "#{TMP_DIR}/myapp.blueprint"
        FileUtils.cp "#{FIXTURES}/lib1.js", "#{TMP_DIR}/src/lib1.js"
        FileUtils.cp "#{FIXTURES}/lib2.js", "#{TMP_DIR}/src/lib2.js"
        FileUtils.cp "#{FIXTURES}/src_file.js", "#{TMP_DIR}/src/myapp.js"
        FileUtils.cp "#{FIXTURES}/_hidden.js", "#{TMP_DIR}/src/"
        @project.update
      end
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
    end

    it 'should update with fresh config values' do
      "#{TMP_DIR}/lib/myapp.js".should be_same_file_as "#{FIXTURES}/update.js"
    end
  end

  context "when compiling underscore template patterns" do
    before :each do
      FileUtils.mkdir("#{TMP_DIR}")
      suppress_output do
        @project = ArchitectureJS::Blueprint.new({ name: 'myapp' },TMP_DIR)
        @project.raise_errors = true
        @project.create
        FileUtils.cp "#{FIXTURES}/underscore_template.js", "#{TMP_DIR}/src/underscore_template.js"
      end
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
    end

    it 'should compile underscore.js template patterns' do
      lambda {
        suppress_output { @project.update }
      }.should_not raise_error
    end
  end

end