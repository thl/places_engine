# 
# ContextualTreeBuilder
# Helps build an html ul tree from any starting point
# Set the @helper for buiding the html fragments
# This class uses a "bottoms up" approach for building the tree
# 
# ContextualTreeBuilder.new({}, MyOptionalHelper).build(optional_context_node)
# 
class ContextualTreeBuilder
  
  def initialize(current_perspective, current_view, options={}, helper=nil)
    # to do: put these methods in as "helpers" instead: def roots(model_instance); # end;
    # then override as needed using @helper
    def_options={
      :model=>nil,
      :roots_method=>:roots,
      :children_method=>:children,
      :parent_method=>:parent,
      :siblings_method=>:siblings
    }
    @options = def_options.merge(options)
    @helper = helper ? helper : self
    @current_perspective = current_perspective
    @current_view = current_view
  end
  
  #

  # node = a node with the methods: children, roots, parent, siblings
  # context = used only by this method
  #
  def build(node, context={}, &block)
    # Prepare to create the child list items
    child_list = ''
    if node.nil?
      send_to(@options[:model], :roots).collect do |node|
        if block_given?
          next unless yield(node)
        end
        child_list += new_list_item(node, nil)
    	end
    	return child_list.html_safe
    end

    # Save the target ID thru all iterations
    context[:target] ||= node

    # loop thru children
    #node.children.each do |child|
    send_to(node, :children).each do |child|
      if block_given?
        next unless yield(child)
      end
      # if this child matches the previous iteration node
      if child==context[:node]
        # use the previously created list
        child_list += context[:list]
      else
        # build a list item
        child_list += new_list_item(child, context[:target])
      end
    end

    # wrap the child list in a ul if needed
    child_list = new_list(child_list.html_safe, node, context[:target])

    # create the top-level list item, include the child list
    if send_to(node, :siblings).size > 0 && ! send_to(node, :parent)
      # if block_given?
      #           next unless yield(node)
      #         end
      list=''
      send_to(@options[:model], :roots).each do |root|
        if block_given?
          next unless yield(root)
        end
        if root == node
          # Added the child list, this is the target node!
          list += new_list_item(root, context[:target]) + child_list
        else
          # parentless sibling
          list += new_list_item(root, context[:target])
        end
      end
    else
      list = new_list_item(node, context[:target]) + child_list
    end

    # If there is a parent to this node
    if send_to(node, :parent)
      dont_skip = true
      if block_given?
        dont_skip = false unless yield(node)
      end
      if dont_skip
        # save the current node
        context[:node]=node
        # save the current list
        context[:list]=list
        # move up to the parent, passing it in the current node and list
        if block_given?
          list = build(send_to(node, :parent), context) {|node| yield(node) }
        else
          list = build(send_to(node, :parent), context)
        end
      end
    end
    # be sure to wrap this list in a ul!
    list
  end
  
  protected
    
    #########################
    ##### "DISPATCHERS" #####
    #########################
    
    #
    # Calls the appropriate method on an instance or class
    # Uses the mapping in @options
    #
    def send_to(node, method)
      node.send(@options["#{method}_method".to_sym].to_sym, @current_perspective, @current_view)
    end
    
    #
    # First calls the helper to get the text/html value
    # then calls the helper.node_li method to wrap
    #
    def new_list_item(node, target)
      @helper.node_li(@helper.node_li_value(node, target), node, target)
    end
    
    #
    # Gets the previously created child_list
    # passes it to the helper.node_ul
    # the node_ul method can then wrap the
    # child list in a new list
    #
    def new_list(child_list, node, target)
      @helper.node_ul(child_list, node, target)
    end
    
    #########################
    #### BUILT-IN HELPERS ###
    #########################

    #
    # Creates a link or static text based on the "target_id"
    #
    def node_li_value(node, target)
      "#{node.class} :: #{node.id}"
    end

    def node_ul(child_list, node, target)
      (child_list.empty? ? '' : "<ul>#{child_list}</ul>")
    end

    def node_li(value, node, target)
      "<li>#{value}</li>"
    end
end