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
  
  def kmaps_url(feature)
    topic_path(feature.fid)
  end
  
  def topical_map_url(feature)
    topics_feature_path(feature.fid)
  end
  
  def geoserver_url
    case InterfaceUtils::Server.environment
    when InterfaceUtils::Server::DEVELOPMENT
      return 'http://dev.thlib.org:8080/thlib-geoserver'
    when InterfaceUtils::Server::LOCAL
      return 'http://localhost:8080/thlib-geoserver'
    else
      return 'http://www.thlib.org:8080/thdl-geoserver'
    end
  end

  def feature_relation_tree(feature)
    v = current_view
    p = current_perspective
    ancestors = feature.current_ancestors(p)
    last_parent = ancestors.last
    parent = ancestors.shift
    if !parent.nil?
      parent_node = {title: parent.prioritized_name(v).name, state: {expanded: true}, enableLinks: true, href: feature_path(parent.fid)}
      tree = [parent_node]
      while parent = ancestors.shift
        parent_node[:children] = [{title: parent.prioritized_name(v).name, state: {expanded: true}}]
        parent_node[:href] = feature_path(parent.fid)
        parent_node = parent_node[:children].first
      end
      children_for_current = nil
      parent_node[:title] << " (#{last_parent.feature_object_types.collect{|fot| fot.category.header}.join(', ')})"
      parent_node[:children] = last_parent.current_children(p,v).collect do |c|
        node = {title: c.prioritized_name(v).name, href: feature_path(c.fid)}
        if feature.fid == c.fid
          node[:backColor] = '#eaeaea'
          node[:expanded] = true
          node[:active] = true
          node[:children] = []
          children_for_current = node[:children]
        end
        node
      end
      children_for_current.concat(feature.all_child_relations
        .collect{|c| {title: "#{c.child_node.prioritized_name(v).name} (from #{c.perspective.name}: #{c.child_node.feature_object_types.collect{|fot| fot.category.header}.join(', ')}; #{c.feature_relation_type.asymmetric_label})", href: feature_path(c.child_node.fid)}})
    else
      tree = []
    end
    apr = []
    if last_parent.nil?
      apr = feature.all_parent_relations
    else
      apr = feature.all_parent_relations.where.not(parent_node_id: last_parent.id)
    end
    parents_not_in_tree = apr.collect{|c| {title: "#{c.parent_node.prioritized_name(v).name} (from #{c.perspective.name}: #{c.parent_node.feature_object_types.collect{|fot| fot.category.header}.join(', ')}; #{c.feature_relation_type.label})", href: feature_path(c.parent_node.fid)}}
    {tree: tree, not_in_tree: parents_not_in_tree}
  end
end
