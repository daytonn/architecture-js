require "spec_helper"

describe ArchitectureJS::Helpers do

  it 'should convert an array to yaml notation' do
    yml = ArchitectureJS::Helpers.array_to_yml ['one', 'two', 'three']
    yml.should == "['one', 'two', 'three']"
  end
end