module ExtendedAdminHelper
  #
  # Express the relationship relative to the "feature" arg node
  #
  def feature_relation_role_label(feature, relation, opts={})
    options={
      :use_first=>true,:use_second=>true,:use_relation=>true,
      :link_first=>true,:link_second=>true,:link_relation=>true
    }.merge(opts)
    relation.role_of?(feature) do |other,sentence|
      items=[]
      if options[:use_first]
        items << (options[:link_first] ? 
          (options[:use_names] ? f_link(feature, admin_feature_path(feature)) : feature_link(feature)) : 
          feature_label(feature))
      end
      if options[:use_relation]
        sentence = sentence
        items << (options[:link_relation] ? link_to(sentence, admin_feature_feature_relation_path(feature, relation)) : sentence)
      end
      if options[:use_second]
        items << (options[:link_second] ? 
          (options[:use_names] ? f_link(other, admin_feature_path(other)) : feature_link(other)) : 
          feature_label(other))
        if options[:show_feature_types]
          items << "(" + other.object_types.collect{|type| type.header }.join(", ") + ")"
        end
      end
      items.join(" ").html_safe
    end
  end
  
  #
  # Allows for specification of what model names should be displayed as to users (e.g. "location" instead of "shape")
  #
  def model_display_name(str)
    names = {
      'association_note' => 'note',
      'description' => 'essay',
      'feature_geo_code' => 'geo_code',
      'feature_name' => 'name',
      'feature_object_type' => 'feature_type',
      'shape' => 'location',
      'time_unit' => 'date',
      'category_feature' => Topic.human_name #'kmap_characteristic'
    }
    names[str].nil? ? str : names[str]
  end
end