require "spec_helper"

describe ArchitectureJS do  
  it 'should have a base_directory constant' do
    ArchitectureJS::base_directory.should_not be_nil
  end
  
  it 'should have a lib_directory constant' do
    ArchitectureJS::lib_directory.should_not be_nil
  end
  
  it 'should have a lib_directory' do
    ArchitectureJS::lib_directory.should_not be_nil
  end
  
  it 'should have the correct VERSION' do
    version = File.open("#{ArchitectureJS::base_directory}/VERSION").read
    ArchitectureJS::VERSION.should === version
  end

  it 'should have a BLUEPRINTS constant' do
    ArchitectureJS::BLUEPRINTS.should_not be_nil
  end

  context "Instantiation with a config file" do

   before :each do
     FileUtils.mkdir("#{TMP_DIR}")
     FileUtils.cp "#{FIXTURES}/existing.blueprint", "#{TMP_DIR}/myapp.blueprint"
     suppress_output { @project = ArchitectureJS::Blueprint.new_from_config(TMP_DIR) }
   end

   after :each do
     FileUtils.rm_rf "#{TMP_DIR}" if File.exists? "#{TMP_DIR}"
   end

   it "should raise an error if there is no .blueprint file" do
     FileUtils.rm_rf "#{TMP_DIR}/myapp.blueprint"
     lambda { ArchitectureJS::Blueprint.new_from_config TMP_DIR }.should raise_error
   end

   it 'should set defaults from config file' do
     @project.config.should == {
       blueprint: 'default',
       src_dir: 'source',
       build_dir: 'dest',
       asset_root: '../',
       output: 'compressed',
       name: 'test',
     }
   end

  end # Instantiation with an existing config file
end
