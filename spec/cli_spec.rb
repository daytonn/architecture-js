require 'spec_helper'
# TODO write tests for CLI
describe 'CLI' do

  before :each do
    @bin = "#{ArchitectureJS::base_directory}/bin/architect"
    FileUtils.mkdir "#{TMP_DIR}" unless File.exists? "#{TMP_DIR}"
    suppress_output { %x(cd #{TMP_DIR}; #{@bin} create myapp) }
    FileUtils.cp "#{FIXTURES}/lib1.js", "#{TMP_DIR}/src/lib1.js"
    FileUtils.cp "#{FIXTURES}/lib2.js", "#{TMP_DIR}/src/lib2.js"
    FileUtils.cp "#{FIXTURES}/src_file.js", "#{TMP_DIR}/src/myapp.js"
  end

	after :each do
    FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
  end

  it 'should create a new application' do
    "#{TMP_DIR}/myapp.architecture".should be_same_file_as "#{FIXTURES}/myapp.architecture"
    File.directory?("#{TMP_DIR}/lib").should be_true
    File.directory?("#{TMP_DIR}/src").should be_true
  end
  
  it 'should create a new application in a subdirectory' do
    suppress_output { %x(cd #{TMP_DIR}; #{@bin} create myapp sub) }
    "#{TMP_DIR}/sub/myapp.architecture".should be_same_file_as "#{FIXTURES}/myapp.architecture"
    File.directory?("#{TMP_DIR}/sub/lib").should be_true
    File.directory?("#{TMP_DIR}/sub/src").should be_true
    File.exists?("#{TMP_DIR}/sub/src/myapp.js").should be_true
    FileUtils.rm_rf "#{TMP_DIR}/sub"
  end

  it 'should compile the application' do
    suppress_output { %x(cd #{TMP_DIR}; #{@bin} compile) }
    File.exists?("#{TMP_DIR}/lib/myapp.js").should be_true
    "#{TMP_DIR}/lib/myapp.js".should be_same_file_as "#{FIXTURES}/compressed.js"
  end

  it 'should generate a template' do
    #suppress_output { %x`cd #{TMP_DIR}; #{@bin} generate blank test` }
    #File.exists?("#{TMP_DIR}/test.js").should be_true
  end

  describe 'alternate framework' do

    before :each do
      @bin = "#{ArchitectureJS::base_directory}/bin/architect"
      FileUtils.mkdir TMP_DIR unless File.exists? TMP_DIR
    end

    after :each do
      FileUtils.rm_rf TMP_DIR
    end
    it 'should create a new application with an alternate framework' do
      puts %x(cd #{TMP_DIR}; #{@bin} create myapp -f test) 
      File.directory?("#{TMP_DIR}/application").should be_true
      File.directory?("#{TMP_DIR}/elements").should be_true
      File.directory?("#{TMP_DIR}/lib").should be_true
      File.directory?("#{TMP_DIR}/models").should be_true
      File.directory?("#{TMP_DIR}/modules").should be_true
      File.directory?("#{TMP_DIR}/plugins").should be_true
      File.directory?("#{TMP_DIR}/spec").should be_true
    end
=begin
    it 'should create a new application in a subdirectory with an alternate framework' do
      suppress_output { %x(cd #{TMP_DIR}; #{@bin} create myapp sub -f test) }

      File.directory?("#{TMP_DIR}/sub/application").should be_true
      File.directory?("#{TMP_DIR}/sub/elements").should be_true
      File.directory?("#{TMP_DIR}/sub/lib").should be_true
      File.directory?("#{TMP_DIR}/sub/models").should be_true
      File.directory?("#{TMP_DIR}/sub/modules").should be_true
      File.directory?("#{TMP_DIR}/sub/plugins").should be_true
      File.directory?("#{TMP_DIR}/sub/spec").should be_true
    end
=end
  end
end