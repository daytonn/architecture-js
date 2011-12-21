require "spec_helper"

describe ArchitectureJS do  
  it 'should have a BASE_DIR constant' do
    ArchitectureJS::BASE_DIR.should_not be_nil
  end
  
  it 'should have a LIB_DIR constant' do
    ArchitectureJS::LIB_DIR.should_not be_nil
  end
  
  it 'should have a ROOT_DIR' do
    ArchitectureJS::ROOT_DIR.should_not be_nil
  end
  
  it 'should have the correct VERSION' do
    version = File.open("#{ArchitectureJS::BASE_DIR}/VERSION").read
    ArchitectureJS::VERSION.should === version
  end

  it 'should have a FRAMEWORKS constant' do
    ArchitectureJS::FRAMEWORKS.should_not be_nil
  end
end
