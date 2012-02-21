require 'spec_helper'

describe 'architect' do

  context "CLI" do
    before :each do
      @bin = "#{ArchitectureJS::base_directory}/bin/architect"
      FileUtils.mkdir "#{TMP_DIR}" unless File.exists? "#{TMP_DIR}"
      `cd #{TMP_DIR}; #{@bin} create myapp`
      FileUtils.cp "#{FIXTURES}/lib1.js", "#{TMP_DIR}/src/lib1.js"
      FileUtils.cp "#{FIXTURES}/lib2.js", "#{TMP_DIR}/src/lib2.js"
      FileUtils.cp "#{FIXTURES}/src_file.js", "#{TMP_DIR}/src/myapp.js"
    end

    after :each do
      FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
    end

    it 'should create a new application' do
      "#{TMP_DIR}/myapp.blueprint".should be_same_file_as "#{FIXTURES}/myapp.blueprint"
      File.directory?("#{TMP_DIR}/lib").should be_true
      File.directory?("#{TMP_DIR}/src").should be_true
    end

    it 'should create a new application in a subdirectory' do
      `cd #{TMP_DIR}; #{@bin} create myapp sub`
      "#{TMP_DIR}/sub/myapp.blueprint".should be_same_file_as "#{FIXTURES}/myapp.blueprint"
      File.directory?("#{TMP_DIR}/sub/lib").should be_true
      File.directory?("#{TMP_DIR}/sub/src").should be_true
      File.exists?("#{TMP_DIR}/sub/src/myapp.js").should be_true
      FileUtils.rm_rf "#{TMP_DIR}/sub"
    end

    it 'should compile the application' do
      `cd #{TMP_DIR}; #{@bin} compile`
      File.exists?("#{TMP_DIR}/lib/myapp.js").should be_true
      "#{TMP_DIR}/lib/myapp.js".should be_same_file_as "#{FIXTURES}/compressed.js"
    end

    it 'should generate a template' do
      `cd #{TMP_DIR}/src; #{@bin} generate blank test`
      File.exists?("#{TMP_DIR}/src/test.js").should be_true
    end

    it 'should generate a template with options' do
      FileUtils.mkdir("#{TMP_DIR}/templates")
      FileUtils.cp("#{FIXTURES}/templates/test_template_two.js", "#{TMP_DIR}/templates/test_template.js")
      `cd #{TMP_DIR}/src; #{@bin} generate test_template foo --optional_variable true --is_good -g --bool`
      
      File.exists?("#{TMP_DIR}/src/foo.js").should be_true
      "#{TMP_DIR}/src/foo.js".should be_same_file_as "#{FIXTURES}/test_template_options.js"
    end

  end

end