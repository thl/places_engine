json.array! @feature.all_child_relations do |c|
  json.title "<strong>#{c.child_node.prioritized_name(@view).name}</strong> (from #{c.perspective.name}: #{c.child_node.feature_object_types.collect{|fot| fot.category.header}.join(', ')}; #{c.feature_relation_type.asymmetric_label})"
  json.href feature_path(c.child_node.fid)
  json.lazy !c.child_node.all_child_relations.empty?
  json.key c.child_node.fid
end
