require "spec_helper"

describe ArchitectureJS::Command do  
  
  context 'API' do
    before :each do
      suppress_output do
        @project = ArchitectureJS::Project.new({ name: 'myapp' }, TMP_DIR)
        @project.create
      end
    end

    after :each do
      FileUtils.rm_rf TMP_DIR
    end

    it 'should have a watch command' do
      ArchitectureJS::Command.should respond_to :watch
    end

    it 'should have a compile command' do
      ArchitectureJS::Command.should respond_to :compile
    end

    it 'should have a generate command' do
      ArchitectureJS::Command.should respond_to :generate
    end

    it 'should have a create command' do
      ArchitectureJS::Command.should respond_to :create
    end
  end
  
  context 'Usage' do
    after :each do
      FileUtils.rm_rf TMP_DIR
    end

    it 'should create a new application' do
      suppress_output { ArchitectureJS::Command.create({ name: 'myapp', root: TMP_DIR }) }

      "#{TMP_DIR}/myapp.architecture".should be_same_file_as "#{FIXTURES}/myapp.architecture"
      File.directory?("#{TMP_DIR}/lib").should be_true
      File.directory?("#{TMP_DIR}/src").should be_true
    end

    it 'should compile the application' do
      suppress_output { ArchitectureJS::Command.create({ name: 'myapp', root: TMP_DIR }) }
      FileUtils.cp "#{FIXTURES}/lib1.js", "#{TMP_DIR}/src/lib1.js"
      FileUtils.cp "#{FIXTURES}/lib2.js", "#{TMP_DIR}/src/lib2.js"
      FileUtils.cp "#{FIXTURES}/src_file.js", "#{TMP_DIR}/src/myapp.js"

      suppress_output { ArchitectureJS::Command.compile({ path: TMP_DIR }) }

      File.exists?("#{TMP_DIR}/lib/myapp.js").should be_true
      "#{TMP_DIR}/lib/myapp.js".should be_same_file_as "#{FIXTURES}/compiled_src.js"
    end
    
  end # Usage
end