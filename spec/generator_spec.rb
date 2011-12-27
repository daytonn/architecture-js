require "spec_helper"

describe ArchitectureJS::Generator do

  before :each do
    FileUtils.mkdir TMP_DIR
    FileUtils.mkdir "#{TMP_DIR}/templates"
    FileUtils.cp "#{FIXTURES}/test_template.erb", "#{TMP_DIR}/templates/test_template.erb"
    FileUtils.cp "#{FIXTURES}/ejs_template.ejs", "#{TMP_DIR}/templates/ejs_template.ejs"
    @gen = ArchitectureJS::Generator.new(ArchitectureJS::Project.new({ name: 'myapp' }, TMP_DIR))
  end
  
  after :each do
    FileUtils.rm_rf TMP_DIR if File.exists? TMP_DIR
  end

  it "should have a project" do
    @gen.project.class.should == ArchitectureJS::Project
  end

  it "should have template_paths" do
    @gen.template_paths.should == ["#{ArchitectureJS::BASE_DIR}/templates", "#{TMP_DIR}/templates"]
  end

  it "should get a template name" do
    @gen.get_template_name("/Volumes/Storage/Development/architecture-js/spec/tmp/templates/ejs_template.ejs").should == 'ejs'
    @gen.get_template_name("/Volumes/Storage/Development/architecture-js/spec/tmp/templates/test_template.erb").should == 'test'
  end

  it "should find all the templates" do
    @gen.templates['test'].should_not be_nil
    @gen.templates['ejs'].should_not be_nil
  end

  it 'should render a template' do
    @gen.render_template('test').should == File.open("#{FIXTURES}/test_template.js").read
  end

  it 'should render a template with options' do
    @gen.render_template('test', optional_variable: 'true').should == File.open("#{FIXTURES}/test_template_options.js").read
  end

  it 'should render templates with different file extensions' do
    @gen.templates['ejs'].is_a?(ERB).should be_true
    @gen.render_template('ejs').should == File.open("#{FIXTURES}/test_template.js").read
    @gen.render_template('ejs', optional_variable: 'true').should == File.open("#{FIXTURES}/test_template_options.js").read
  end

end