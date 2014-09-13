# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'table_plus_index/version'

Gem::Specification.new do |spec|
  spec.name          = "table_plus_index"
  spec.version       = TablePlusIndex::VERSION
  spec.authors       = ["Donald R. Ziesig"]
  spec.email         = ["donald@ziesig.org"]
  spec.summary       = %q{Save context for table and table-plus}
  spec.description   = <<DOC
One of my clients has tables with thousands of rows which are related positionally 
(adjacency is relevant) and have searchable values. Once a row is found it is often 
used in many subsequent operations. Consequently using the page navigator for rows 
in the middle of the current sort order is cumbersome.

It was requested that I save the context between visits to the index pages to avoid 
the “page chase” that occurred when the user needed to return to the most recent row
(or adjacent rows).

Inspired by Dean’s technique of saving filter_parameters in the session, but needing 
a more general solution, I put together a gem to save and restore the context from
within the controllers of the various tables. The original version of this code was
published in the 'Recipies' section of hobocentral.net and was rather verbose
(subsequent versions of Hobo and Ruby broke it, too).

The resulting gem is so convenient to use that now I include it in all of my hobo 
projects.

The gem requires a hobo_model_controller that truly references a model and replaces
the call to hobo_index within the index method.

Invocation is as follows:

class MyController < ApplicationController

  hobo_model_controller

  auto_actions :all       # may be changed to reflect app needs

  include TablePlusIndex

  def index
    table_plus_index( self,                     # needs the controller itself
                      6,                        # the number of records per page (>0)
                      [:name, :street, :city],  # array of columns to be searched
                      [:picture],               # array of columns to be ignored (or nil)
                                                # typically containing large data
                      :name, :city, :zipcode )  # columns which may be sorted by
                                                # table-plus.
    # table_plus_index may be followed by an optional block which is passed to hobo_index
  end

  *
  *
  *
end

DOC
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "hobo", "~> 2.0"

end
