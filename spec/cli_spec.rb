require 'spec_helper'

describe 'CLI' do
  before :each do
    @bin = "#{ArchitectureJS::BASE_DIR}/bin/arcjs"
    FileUtils.mkdir "#{TMP_DIR}" unless File.exists? "#{TMP_DIR}"
    suppress_output { %x(cd #{TMP_DIR}; #{@bin} create myapp) }
    FileUtils.cp "#{FIXTURES}/lib1.js", "#{TMP_DIR}/lib/lib1.js"
    FileUtils.cp "#{FIXTURES}/lib2.js", "#{TMP_DIR}/lib/lib2.js"
    FileUtils.cp "#{FIXTURES}/src_file.js", "#{TMP_DIR}/src/myapp.js"
  end

	after :each do
    FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
  end

  it 'should create a new application' do
    "#{TMP_DIR}/myapp.conf".should be_same_file_as "#{FIXTURES}/myapp.conf"
    File.directory? "#{TMP_DIR}/lib"
    File.directory? "#{TMP_DIR}/src"
  end
  
  it 'should create a new application in a subdirectory' do
    suppress_output { %x(cd #{TMP_DIR}; #{@bin} create myapp sub) }
    "#{TMP_DIR}/sub/myapp.conf".should be_same_file_as "#{FIXTURES}/myapp.conf"
    File.directory? "#{TMP_DIR}/sub/lib"
    File.directory? "#{TMP_DIR}/sub/src"
    File.exists? "#{TMP_DIR}/sub/myapp.js"
    FileUtils.rm_rf "#{TMP_DIR}/sub"
  end

  it 'should compile the application' do
    suppress_output { %x(cd #{TMP_DIR}; #{@bin} compile) }
    File.exists?("#{TMP_DIR}/myapp.js").should be_true
    "#{TMP_DIR}/myapp.js".should be_same_file_as "#{FIXTURES}/compiled_src.js"
  end

end