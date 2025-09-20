module PlacesEngine
  module FeatureRelationExtensions
    extend ActiveSupport::Concern

    included do
      after_save do |record|
        [record.parent_node, record.child_node].each { |r| r.update_cached_feature_relation_categories if !r.nil? }
      end
      
      after_destroy do |record|
        [record.parent_node, record.child_node].each { |r| r.update_cached_feature_relation_categories if !r.nil? }
      end
    end
    
    module ClassMethods
    end
  end
end