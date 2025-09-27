# Methods added to this helper will be available to all templates in the application.
module PlacesEngineHelper
  def custom_secondary_tabs_list
    # The :index values are necessary for this hash's elements to be sorted properly
    {
      :place => {:index => 1, :title => 'Overview', :shanticon => 'overview'},
      :descriptions => {:index => 2, :title => 'Essays', :shanticon => 'texts'},
      :related => {:index => 3, :title => Feature.model_name.human(count: :many).titleize, :shanticon => 'places'}
    }
  end
    #
  # Creates a breadcrumb trail to the feature
  #
  def f_places_breadcrumb
    ancestor_list = @feature&.closest_ancestors_by_perspective(current_perspective).drop(1)
    f_breadcrumb(ancestor_list)
  end

  
  def kmaps_url(feature)
    topic_path(feature.fid)
  end
  
  def topical_map_url(feature)
    topics_feature_path(feature.fid)
  end
  
  def geoserver_url
    PlacesEngine::Configuration.geoserver_url
  end

  def feature_relation_tree(feature, show_siblings = false)
    v = current_view
    p = current_perspective
    ancestors = feature.current_ancestors(p)
    last_parent = ancestors.last
    parent = ancestors.shift
    tree = []
    parent_node = nil
    children_for_current = nil
    if !parent.nil?
      parent_node = {title: "<strong>#{parent.prioritized_name(v).name}</strong>", state: {expanded: true}, href: feature_path(parent.fid), key: parent.fid}
      tree = [parent_node]
      while parent = ancestors.shift
        parent_node[:children] = [{title: "<strong>#{parent.prioritized_name(v).name}</strong>", state: {expanded: true}}]
        parent_node[:href] = feature_path(parent.fid)
        parent_node = parent_node[:children].first
      end
      parent_node[:title] << " (#{last_parent.feature_object_types.collect{|fot| fot.category.header}.join(', ')})"
    end
    if show_siblings
      parent_node[:children] = last_parent.current_children(p,v).collect do |c|
        node = {title: "<strong>#{c.prioritized_name(v).name}</strong>", href: feature_path(c.fid), key: c.fid}
        if feature.fid == c.fid
          node[:backColor] = '#eaeaea'
          node[:expanded] = true
          node[:active] = true
          node[:children] = []
          children_for_current = node[:children]
        end
        node
      end
    else
      node = { title: "<strong>#{feature.prioritized_name(v).name}</strong>",
               href: feature_path(feature.fid),
               key: feature.fid,
               backColor: '#eaeaea',
               expanded: true,
               active: true,
               children: []}
      children_for_current = node[:children]
      if parent_node.nil?
        tree = [ node ]
      else
        parent_node[:children] = [ node ]
      end
    end
    children_for_current.concat(feature.all_child_relations
      .collect{|c| {title: "<strong>#{c.child_node.prioritized_name(v).name}</strong> (from #{c.perspective.name}: #{c.child_node.feature_object_types.collect{|fot| fot.category.header}.join(', ')}; #{c.feature_relation_type.asymmetric_label})", href: feature_path(c.child_node.fid), lazy: true, key: c.child_node.fid,}})
    apr = []
    if last_parent.nil?
      apr = feature.all_parent_relations
    else
      apr = feature.all_parent_relations.where.not(parent_node_id: last_parent.id)
    end
    parents_not_in_tree = apr.collect{|c| {title: "<strong>#{c.parent_node.prioritized_name(v).name}</strong> (from #{c.perspective.name}: #{c.parent_node.feature_object_types.collect{|fot| fot.category.header}.join(', ')}; #{c.feature_relation_type.label})", href: feature_path(c.parent_node.fid)}}
    {tree: tree, not_in_tree: parents_not_in_tree}
  end
end
