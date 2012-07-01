require "spec_helper.rb"

describe 'Templates' do

  describe 'without template files' do

    before :each do
      FileUtils.mkdir TMP_DIR
      suppress_output do
        @project = ArchitectureJS::Blueprint.new({ name: 'myapp' }, TMP_DIR)
        @project.create
      end
      suppress_output { @project.update }
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
    end

    it 'should not create a templates.js file in the build_dir' do
      File.exists?("#{TMP_DIR}/lib/templates.js").should be_false
    end

  end

  describe "with one template_dir and one template file" do
    before :each do
      FileUtils.mkdir TMP_DIR
      suppress_output do
        @project = ArchitectureJS::Blueprint.new({ name: 'myapp' }, TMP_DIR)
        @project.create
      end
      FileUtils.mkdir "#{TMP_DIR}/templates"
      FileUtils.cp "#{FIXTURES}/test_template.jst", "#{TMP_DIR}/templates/test_template.jst"
      suppress_output { @project.update }
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
    end

    it 'should have one template' do
      @project.templates['test_template'].should_not be_nil
    end

    it 'should create a templates file in the build directory' do
      File.exists?("#{TMP_DIR}/lib/templates.js").should be_true
    end

  end

  describe 'with multiple template_dirs and multiple templates' do
    before :each do
      FileUtils.mkdir TMP_DIR
      suppress_output do
        project = ArchitectureJS::Blueprint.new({ name: 'myapp' }, TMP_DIR)
        project.create
        FileUtils.cp "#{FIXTURES}/multiple_templates.blueprint", "#{TMP_DIR}/myapp.blueprint"
        FileUtils.mkdir "#{TMP_DIR}/templates"
        FileUtils.mkdir "#{TMP_DIR}/more_templates"
        FileUtils.cp "#{FIXTURES}/test_template.jst", "#{TMP_DIR}/templates/test_template.jst"
        FileUtils.cp "#{FIXTURES}/test_template.jst", "#{TMP_DIR}/more_templates/another_template.jst"
        @project = ArchitectureJS::Blueprint.init_with_config(TMP_DIR)
      end
      suppress_output { @project.update }
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
    end

    it 'should use alternate namespace' do
      File.read("#{TMP_DIR}/lib/templates.js").match(/^myapp\.Foo/).should be_true
    end

    it 'should have multiple template directories' do
      puts @project.template_directories
      @project.template_directories.length.should == 2
    end

    it 'should have two templates' do
      @project.templates['test_template'].should_not be_nil
      @project.templates['another_template'].should_not be_nil
    end

    it 'should create a templates file in the build directory' do
      File.exists?("#{TMP_DIR}/lib/templates.js").should be_true
    end

  end

end