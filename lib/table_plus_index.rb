require "table_plus_index/version"

module TablePlusIndex

  def table_plus_index( controller, per_page, search_columns, ignore_columns, *sort_columns)
#ensure that this is a hobo controller that has an associated model.  Note that methods.include? is
#used in place of respond_to? because controller.respond_to? :hobo_index is false even though it 
#does respond to hobo_index    
    raise "TablePlusAssistant requires a Hobo controller" unless controller.methods.include? :hobo_index
    model = controller.model
    raise "TablePlusAssistant requires a controller with an associated model" if model.nil?

# Save the parameters for next invocation
    save_param(params,:sort,session)
    save_param(params,:search,session)

# If we have fields to ignore (usually ones with much data),
# get a list of all columns excluding them.
    if ignore_columns.nil?
      field_list = model.column_names
    else
      if ignore_columns.is_a? String
        ign = ignore_columns.split(%r{[,\s*]})
        ign.each do |col| col.strip! end
        puts "ignore:  #{ign.inspect}"
        field_list = model.column_names.select{ |col| ign.find_index(col).nil? }
      elsif ignore_columns.is_a? Array
        ign = []
        ignore_columns.each do |col| ign << col.to_s.strip end
        field_list = model.column_names.select{ |col| ign.find_index(col).nil? }
      else
        raise "ignore_columns must be nil, a String or an Array"
      end
    end

    sort_order = controller.parse_sort_param(*sort_columns) # this feeds back to table-plus arrows

    # finder = model.apply_scopes(  :order_by => sort_order,
    #                               :search => [params[:search]] + search_columns).select(field_list)

    finder = model.unscoped do
      model.apply_scopes( :order_by => sort_order,
                          :search => [params[:search]] + search_columns).select(field_list)
    end


# pass the block to the hobo_index if necessary
    if block_given?
      controller.hobo_index(  finder,
                              :per_page => per_page,
                              :page => save_page(params, per_page, session, finder ), 
                            &Proc.new )
    else                                                
      controller.hobo_index(  finder,
                              :per_page => per_page,
                              :page => save_page(params, per_page, session, finder ) )
    end                                         
  end

private

  def save_page(params, per_page, session, table)
# Default to the first page.
    page = 1
# Generate a session key from the name of the table.
    controller = params[:controller]
    key = controller+'-page'

    if params[:page]
# If we have a page parameter, save it in the session
      page = params[:page].to_i      
      session[key] = page
    else
# If we don't have a page parameter get the page from the session if it exists
      if session[key]
        page = session[key]
      else
        page = 1
      end
    end
# Make sure that the page is not beyond a possibly truncated table (learned the hard way)
    page_count = (table.count.to_f/per_page.to_f).ceil
    if page_count < page
      page = 1
      session[key] = page
    end

    return page
  end

  def save_param(params,param,session)
    controller = params[:controller]
    key = controller + '-' + param.to_s
    if params[param]
# If we have a value in params[param], save it in the session
      value = params[param]
      session[key] = value
    else
      value = session[key] if session[key].is_a? String
    end
# set params[param] if we have a value.
    params[param] = value if value
    params[param]    
  end

end
