require "spec_helper"

describe ArchitectureJS::Helpers do
  it 'should create a module filename from a POSIX path' do
    ArchitectureJS::Helpers.get_file_name('/some/path/some.module.js').should === 'some'
  end
  
  it 'should create a module filename from a Windows path' do
    ArchitectureJS::Helpers.get_file_name('D:\\\\some\path\some.module.js').should === 'some'
  end

  it 'should convert an array to yaml notation' do
    yml = ArchitectureJS::Helpers.array_to_yml ['one', 'two', 'three']
    yml.should == "['one', 'two', 'three']"
  end
end