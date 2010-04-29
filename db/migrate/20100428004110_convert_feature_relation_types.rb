class ConvertFeatureRelationTypes < ActiveRecord::Migration
  def self.up
    FeatureRelationType.destroy_all
    
    types = {
      '' => {:is_symmetric => false, :label => 'is a parent of', :asymmetric_label => 'is subordinate to'},
      :adjacent => {:is_symmetric => true, :label => 'is adjacent to'},
      :intersects => {:is_symmetric => true, :label => 'intersects with'},
      :instantiation => {:is_symmetric => false, :label => 'is an instantiation of', :asymmetric_label => 'has as an instantiation of it'},
      :near => {:is_symmetric => true, :label => 'is near'},
      :located => {:is_symmetric => false, :label => 'is contained by', :asymmetric_label => 'contains'},
      :part => {:is_symmetric => false, :label => 'is part of', :asymmetric_label => 'has as part of it'},
      :related => {:is_symmetric => true, :label => 'is related to'},
      :admin_seat => {:is_symmetric => false, :label => 'is administrative seat of', :asymmetric_label => 'has as an administrative seat'},
      :admin_headquarters => {:is_symmetric => false, :label => 'is administrative headquarters of', :asymmetric_label => 'has as an administrative headquarters'},
      :conflict => {:is_symmetric => true, :label => 'is in conflict with'},
      :affiliated => {:is_symmetric => true, :label => 'is affiliated with'}
    }
    
    types.each do |old_role, type|
      type[:asymmetric_label] = type[:label] if type[:is_symmetric]
      created_type = FeatureRelationType.create(type)
      # Do these values need to be sanitized?
      conditions = old_role == '' ? "role IS NULL OR role = ''" : "role = '#{old_role}'"
      FeatureRelation.update_all("feature_relation_type_id = #{created_type.id}", conditions)
    end
  end

  def self.down
    FeatureRelation.update_all("feature_relation_type_id = NULL")
    FeatureRelationType.destroy_all
  end
end