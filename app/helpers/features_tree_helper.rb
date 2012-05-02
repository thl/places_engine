#
# This module isn't part of any controller etc.,
# just here to be shared as needed
#
module FeaturesTreeHelper  
  def new_tree_builder
    # This class is in lib/
    ContextualTreeBuilder.new(current_perspective, current_view,
      {:model=>Feature,
      :parent_method=>:current_parent,
      :children_method=>:current_children,
      :roots_method=>:current_roots,
      :siblings_method=>:current_siblings},
      self # pass is self so we can override the helper methods
    )
  end
  
  #
  # You can override this method in the Helper that includes... this helper
  #
  def node_ul(child_list, node, target)
    child_list.empty? ? '' : content_tag(:ul, child_list)
  end
  
  #
  # You can override this method in the Helper that includes... this helper
  #
  def node_li(value, node, target)
    css_class = ''
    if node.children.size > 0
      css_class = (target && ( target.id == node.id || target.ancestors.include?(node) )) ? 'opened' : 'closed'
    else
      css_class = 'single'
    end
    content_tag(:li, value, :class=>css_class)
  end
  
  #
  # You can override this method in the Helper that includes... this helper
  #
  def node_li_value(node, target)
    node.to_s
  end
end