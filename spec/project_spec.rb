require "spec_helper.rb"

describe ArchitectureJS::Project do

  it "should exist" do
    ArchitectureJS::Project.should_not be_nil
  end

  context 'Instantiation' do
    before :each do
      FileUtils.mkdir TMP_DIR
      suppress_output do
        @project = ArchitectureJS::Project.new('myapp', { root: TMP_DIR })
      end
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
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

  end # Instantiation
=begin
  context "Instantiation with a config file" do

   before :each do
     FileUtils.mkdir("#{TMP_DIR}")
     FileUtils.cp "#{FIXTURES}/existing.conf", "#{TMP_DIR}/myapp.conf"
     suppress_output { @project = ArchitectureJS::Project.init_with_config({ root: "#{TMP_DIR}" }) }
   end

   after :each do
     FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
   end

   it 'should throw and error when no config exists' do
     FileUtils.rm_rf "#{TMP_DIR}/myapp.conf"
     lambda {
       ArchitectureJS::Project.init_with_config root: "#{TMP_DIR}"
     }.should raise_error
   end

   it 'should set defaults from config file' do
     @project.config.should == {
       name: 'test',
       framework: 'custom',
       src_dir: 'source',
       dest_dir: 'dest',
       output: 'compressed'
     }
   end
  end # Instantiation with an existing config file

  context "Project Creation" do
   before :each do
     FileUtils.mkdir("#{TMP_DIR}")
     suppress_output do
       @project = ArchitectureJS::Project.new('myapp', { root: "#{TMP_DIR}" })
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
     File.exists?("#{TMP_DIR}/myapp.conf").should be_true
     "#{TMP_DIR}/myapp.conf".should be_same_file_as "#{FIXTURES}/myapp.conf"
   end

  end # Project Creation

  context "Project Update" do
    before :each do
      FileUtils.mkdir("#{TMP_DIR}")
      suppress_output do
        @project = ArchitectureJS::Project.new('myapp', { root: "#{TMP_DIR}" })
        @project.create
        FileUtils.cp "#{FIXTURES}/lib1.js", "#{TMP_DIR}/lib/lib1.js"
        FileUtils.cp "#{FIXTURES}/lib2.js", "#{TMP_DIR}/lib/lib2.js"
        FileUtils.cp "#{FIXTURES}/src_file.js", "#{TMP_DIR}/src/myapp.js"
        @project.update
      end
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
    end

    it 'should compile the source files into the destination folder' do
      File.exists?("#{TMP_DIR}/lib/myapp.js").should be_true
      "#{TMP_DIR}/lib/myapp.js".should be_same_file_as "#{FIXTURES}/compiled_src.js"
    end

  end # Project Update
=end
end