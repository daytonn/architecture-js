$: << File.join(File.dirname(__FILE__), "../lib")

require 'architecture-js'
require 'fileutils'
require 'rspec'
require 'digest/md5'
require 'fixtures/test_blueprint.rb'

RSpec.configure do |config|
  config.color_enabled = true
end

RSpec::Matchers.define(:be_same_file_as) do |epxected_file_path|
  match do |actual_file_path|
    md5_hash(actual_file_path).should == md5_hash(epxected_file_path)
  end
  
  def md5_hash(file_path)
    Digest::MD5.hexdigest(File.read(file_path))    
  end
end

def suppress_output(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  
  fake.string
end

SPEC_DIR = "#{ArchitectureJS::base_directory}/spec"
TMP_DIR = "#{SPEC_DIR}/tmp"
FIXTURES = "#{SPEC_DIR}/fixtures"