#!/usr/bin/env rake
require "bundler/gem_tasks"
 
require 'rake/testtask'
 
Rake::TestTask.new do |t|
  t.libs << 'lib/table_plus_index'
  t.test_files = FileList['test/lib/table_plus_index/*_test.rb']
  t.verbose = true
end
 
task :default => :test
