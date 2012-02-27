require 'spec_helper'

describe ArchitectureJS::Generator do

  before :each do
    FileUtils.mkdir TMP_DIR
    FileUtils.mkdir "#{TMP_DIR}/templates"
    FileUtils.cp "#{FIXTURES}/templates/test_template_one.js", "#{TMP_DIR}/test_template_one.js"
    FileUtils.cp "#{FIXTURES}/templates/test_template_two.js", "#{TMP_DIR}/test_template_two.js"
    FileUtils.cp "#{FIXTURES}/templates/env_template.js", "#{TMP_DIR}/env_template.js"

    project = ArchitectureJS::Blueprint.new({ name: 'myapp' }, TMP_DIR)
    project.add_templates "#{FIXTURES}/templates"
    @gen = project.generator
  end

  after :each do
    FileUtils.rm_rf TMP_DIR if File.exists? TMP_DIR
  end

  it 'should have a project' do
    @gen.project.class.should == ArchitectureJS::Blueprint
  end

  it 'should have a blueprint' do
    @gen.blueprint.class.should_not be_nil
  end

  it 'should have template_paths' do
    @gen.template_paths.should == ["#{ArchitectureJS::base_directory}/templates", "#{TMP_DIR}/templates", "#{FIXTURES}/templates"]
  end

  it 'should find all the templates' do
    @gen.templates['test_template_one'].should_not be_nil
    @gen.templates['test_template_two'].should_not be_nil
  end

  it 'should render a template' do
    @gen.render_template('test_template_one', 'test', [], {}).should == File.open("#{FIXTURES}/templates/test_template_one.js").read
    @gen.render_template('test_template_two', 'test', [], {}).should == File.open("#{FIXTURES}/test_template_two.js").read
  end

  it 'should render a template with options' do
    @gen.render_template('test_template_two', 'test', [], { optional_variable: 'true' }).should == File.open("#{FIXTURES}/test_template_options.js").read
  end

  it 'should generate a file from a template' do
    @gen.generate_file("test.js", @gen.render_template("test_template_two", "test", [], {}), TMP_DIR)
    File.exists?("#{TMP_DIR}/test.js").should be_true
    File.open("#{TMP_DIR}/test.js").read.should == File.open("#{FIXTURES}/test_template_two.js").read
  end

  it 'should pass the arguments to the template' do
    @gen.generate_file("env-test.js", @gen.render_template("env_template", "env-test", ['module', 'foo', '-f', '--name', 'Something'], {}), TMP_DIR)
    File.open("#{TMP_DIR}/env-test.js").read.should == File.open("#{FIXTURES}/env-test.js").read
  end
end