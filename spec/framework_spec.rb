require "spec_helper.rb"
# TODO test config creation
describe ArchitectureJS::Framework do

  it 'should exist' do
    ArchitectureJS::Framework.should_not be_nil
  end

  context 'Instantiation' do

    before :each do
      suppress_output { @fw = ArchitectureJS::Framework.new 'myapp', TMP_DIR }
    end

    it 'should have a manifest' do
      @fw.manifest.should == ['lib', 'src']
    end

    it 'should have a config hash' do
      @fw.config.should == {
        src_dir: 'src',
        dest_dir: 'lib',
        output: 'compressed',
        name: 'myapp'
      }
    end

    it 'should have a create method' do
      @fw.respond_to?("create").should be_true
    end

    it 'should have an update method' do
      @fw.respond_to?("update").should be_true
    end


  end # Instantiation

end