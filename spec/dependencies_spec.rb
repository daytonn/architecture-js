require "spec_helper"

describe ArchitectureJS do
  it 'should require yaml ' do
    YAML.should_not be_nil
  end
  
  it 'should require jsmin' do
    JSMin.should_not be_nil
  end
  
  it 'should require tempfile' do
    Tempfile.should_not be_nil
  end
  
  it 'should require sprockets' do
    Sprockets.should_not be_nil
  end
  
  it 'should require fileutils' do
    FileUtils.should_not be_nil
  end
  
  it 'should require time' do
    Time.should_not be_nil
  end

  it 'should require ERB' do
    ERB.should_not be_nil
  end

end