require "spec_helper"

describe ArchitectureJS::Generator do

  before :each do
    FileUtils.mkdir TMP_DIR
    FileUtils.mkdir "#{TMP_DIR}/templates"
    FileUtils.cp "#{FIXTURES}/test_template.erb", "#{TMP_DIR}/templates/test_template.erb"
    FileUtils.cp "#{FIXTURES}/ejs_template.ejs", "#{TMP_DIR}/templates/ejs_template.ejs"
    @gen = ArchitectureJS::Generator.new "#{TMP_DIR}/templates"
  end
  
  after :each do
    FileUtils.rm_rf TMP_DIR if File.exists? TMP_DIR
  end

  it 'should have a template_dir' do
    @gen.template_dir.should == "#{TMP_DIR}/templates"
  end

  it 'should have template files' do
    @gen.template_files.should == ['ejs_template.ejs', 'test_template.erb']
  end

  it 'should have templates' do
    @gen.templates['test_template'].should_not be_nil
    @gen.templates['test_template'].is_a?(ERB).should be_true
  end

  it 'should render a template' do
    project = ArchitectureJS::Project.new { name: 'myapp' }, { root: TMP_DIR }
    @gen.render_template('test_template', project).should == File.open("#{FIXTURES}/test_template.js").read
  end

  it 'should render a template with options' do
    project = ArchitectureJS::Project.new root: TMP_DIR
    @gen.render_template('test_template', project, optional_variable: 'true').should == File.open("#{FIXTURES}/test_template_options.js").read
  end

  it 'should render templates with different file extensions' do
    @gen.templates['ejs_template'].is_a?(ERB).should be_true
    project = ArchitectureJS::Project.new root: TMP_DIR
    @gen.render_template('ejs_template', project).should == File.open("#{FIXTURES}/test_template.js").read
    @gen.render_template('ejs_template', project, optional_variable: 'true').should == File.open("#{FIXTURES}/test_template_options.js").read
  end
end