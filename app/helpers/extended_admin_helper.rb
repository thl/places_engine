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
          (options[:use_names] ? f_link(feature, admin_feature_path(feature.fid)) : feature_link(feature)) :
          feature_label(feature))
      end
      if options[:use_relation]
        sentence = sentence
        items << (options[:link_relation] ? link_to(sentence, admin_feature_feature_relation_path(feature, relation)) : sentence)
      end
      if options[:use_second]
        items << (options[:link_second] ? 
          (options[:use_names] ? f_link(other, admin_feature_path(other.fid)) : feature_link(other)) :
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
      'association_note' => Note.model_name.human,
      'description' => Description.model_name.human,
      'feature' => Feature.model_name.human,
      'feature_geo_code' => FeatureGeoCode.model_name.human,
      'feature_name' => FeatureName.model_name.human,
      'feature_object_type' => 'feature_type',
      'shape' => Shape.model_name.human,
      'time_unit' => 'date',
      'category_feature' => Topic.human_name #'kmap_characteristic'
    }
    names[str].nil? ? str : names[str]
  end

  def add_places_breadcrumb_base
    add_breadcrumb_base
    case parent_type
    when :altitude
      # parent_object is FeatureObjectType
      add_breadcrumb_item link_to(Altitude.model_name.human(:count => :many).s, admin_feature_altitudes_path(parent_object.feature))
      add_breadcrumb_item link_to(parent_object.id, admin_feature_altitude_path(parent_object.feature, parent_object))
    when :category_feature
      # parent_object is FeatureObjectType
      add_breadcrumb_item link_to(Topic.human_name(:count => :many).s, admin_feature_category_features_path(parent_object.feature))
      add_breadcrumb_item link_to(parent_object.id, admin_category_feature_path(parent_object))
    when :feature_object_type
      # parent_object is FeatureObjectType
      add_breadcrumb_item link_to(Feature.human_attribute_name(:object_type, :count => :many).s, admin_feature_feature_object_types_path(parent_object.feature))
      add_breadcrumb_item link_to(parent_object.id, admin_feature_object_type_path(parent_object))
    when :shape
      add_breadcrumb_item link_to(Shape.model_name.human(:count => :many).s, admin_feature_shapes_path(parent_object))
      add_breadcrumb_item link_to(parent_object.to_s, admin_feature_shape_path(parent_object.feature, parent_object))
    end
  end
end
