require "table_plus_index/version"

module TablePlusIndex

  def table_plus_index( controller, per_page, search_columns, ignore_columns, *sort_columns)
#ensure that this is a hobo controller that has an associated model.  Note that methods.include? is
#used in place of respond_to? because controller.respond_to? :hobo_index is false even though it 
#does respond to hobo_index    
    raise "TablePlusIndex requires a Hobo controller" unless controller.methods.include? :hobo_index
    model = controller.model
    raise "TablePlusIndex requires a controller with an associated model" if model.nil?

# make sure per_page is > 0
    if per_page < 1
      logger.warn "TablePlusIndex per_page < 1 (#{per_page}) defaulting to 6"
      per_page = 6
    end
# Fix the sord parameter if it contains something not in the sort_columns.
# This eliminates the unexpected re-ordering if the header for a non-sort
# column is clicked.

    sort_col = params[:sort].to_s
    sort_col = sort_col[0] == '-' ? sort_col[1..-1] : sort_col
    sort_col = sort_col.to_sym
    unless sort_columns.include? sort_col
      params[:sort] = nil
    end

# Save the parameters for next invocation
    save_param(params,:sort,session)
    save_param(params,:search,session)

# If we have fields to ignore (usually ones with much data),
# get a list of all columns excluding them.
    field_list = column_list( ignore_columns, model, true)
    search_cols = column_list( search_columns, model )
    if search_cols.length < 1
      unless params[:search].blank?
        raise "TablePlusIndex search requested on with invalid column.  See log for details"
      end
    end

    sort_order = controller.parse_sort_param(*sort_columns) # this feeds back to table-plus arrows

    finder = model.unscoped do
      model.apply_scopes( :search => [params[:search]] + search_cols).
            apply_scopes( :order_by => sort_order ).select(field_list)
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

  def column_list( columns, model, ign = false )
    if columns.nil?
      if ign 
        result = []
      else
        result = model.column_names
      end
    else
      cols = []
      if columns.is_a? String
        cols = columns.split(%r{[,\s*]})
        cols.each do |col| col.strip! end
        result = model.column_names.select{ |col| cols.find_index(col).nil? ^ !ign }
      elsif columns.is_a? Array
        cols = []
        columns.each do |col| cols << col.to_s.strip end
        result = model.column_names.select{ |col| cols.find_index(col).nil? ^ !ign }
      else
        raise "columns must be nil, a String or an Array"
      end
      if Rails.env.development?
        cols.each do |col| 
          if (not col.empty?) and model.column_names.find_index(col).nil?
            logger.debug "TablePlusIndex:  table #{model.name} does not have a column named #{col}"
          end
        end
      end
    end
    result
  end

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
    elsif session[key].is_a? String
      value = session[key]
    else
      value = nil
      # if sort_cols.length > 0 
      #    value = sort_cols[0].to_s
      #   session[key] = value
      # end
    end
# set params[param] if we have a value.
    params[param] = value if value
    # params[param]    # Don't need return value.
  end

end
