# TablePlusIndex

Save search and page context for table and table-plus

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

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'table_plus_index', :git => 'https://github.com/dziesig/table_plus_index.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install table_plus_index, :git => 'https://github.com/dziesig/table_plus_index.git'

## Usage

```ruby
class MyController < ApplicationController

  hobo_model_controller

	auto_actions :all       # may be changed to reflect app needs

	include TablePlusIndex

	def index
	  table_plus_index( self,                     # needs the controller itself
	                    6,                        # the number of records per page (>0)
	                    search_columns,  					# columns to be searched
	                    ignore_column,            # columns to be ignored (or nil)
	                    :name, :city, :zipcode )  # columns which may be sorted by
	                                              # table-plus.

	  # table_plus_index may be followed by an optional block which is passed to hobo_index

	end

	*
	*
	*
end
```

"search_columns" contains the names of **one** or more columns which will be searched
from the table_plus search box. This may take the form of a string, an array of
strings or an array of symbols:

'name', 'name, rank, serial_number', ['name', 'rank', 'serial_number'],
[:name, :rank, :serial_number] or [:name, 'rank', 'serial_number']

NOTE:  	Due to a bug in the underlying system (at least when using postgresql),
				do not specify a numeric column as one of the search columns or any
				non-blank search will raise an exception.

"ignore_columns" contains the names of zero or more columns which will be removed
from the results.  Typically this is only needed if there are columns with large
amounts of data which are not needed by the index page. This may take the form of 
a string, an array of strings, an array of symbols, or nil:

'name', 'name, rank, serial_number', ['name', 'rank', 'serial_number'],
[:name, :rank, :serial_number] or [:name, 'rank', 'serial_number'], nil



## Contributing

1. Fork it ( https://github.com/[my-github-username]/table_plus_index/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

I have tested this gem extensively using a local test application (the original
code has been in use since 2011).  I have attempted to incorporate tests in the
gem itself, but the test requires me to include almost the entire test application
in the gem, increasing its size by hundreds of times and still giving me circular
dependencies.  I would appreciate any help in putting reasonable tests in the gem.
