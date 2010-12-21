require 'rubygems'
require 'rake'
require 'bundler'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name        = "beast3"
    gemspec.summary     = "Rails 3 version of altered beast"
    gemspec.description = "An engine that enable forum feature for your website."
    gemspec.email       = "chien.cc.kuo@gmail.com"
    gemspec.files       = FileList['lib/**/*.rb', 'README.markdown']
    gemspec.homepage    = "http://nowhere"
    gemspec.authors     = ["Chien Kuo"]
    gemspec.add_dependency('rails', '3.0.3')
    gemspec.add_dependency('devise', '1.1.5')
    gemspec.add_dependency('cancan', '1.4.1')    
    gemspec.add_dependency('will_paginate', '3.0.pre2')
    gemspec.add_dependency('has_permalink', '0.0.5')
    gemspec.add_dependency('RedCloth', '4.2.3')    
    gemspec.add_dependency('acts_as_list', '0.1.2')
    gemspec.add_dependency('haml', '3.0.24')
  end
  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "beast3 #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
