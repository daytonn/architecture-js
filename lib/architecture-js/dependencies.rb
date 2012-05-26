begin
  require 'tempfile'
  require 'fileutils'
  require 'time'
  require 'erb'
  require 'yaml'
  require 'jsmin'
  require 'listen'
rescue LoadError
  require 'rubygems'
  require 'tempfile'
  require 'fileutils'
  require 'time'
  require 'erb'
  require 'yaml'
  require 'jsmin'
  require 'listen'
end